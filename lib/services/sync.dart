import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/core/utils/uuid.dart';
import 'package:poddr/data/settings/settings_repository.dart';
import 'package:poddr/data/settings/secure_settings_repository.dart';
import 'package:poddr/data/settings/prefs_settings_repository.dart';
import 'package:poddr/data/sync/gpodder_client.dart';
import 'package:poddr/data/sync/sync_repository.dart';
import 'package:poddr/data/sync/drift_sync_repository.dart';
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/services/history.dart';
import 'package:poddr/core/validators.dart';

enum SyncStatus {
  disconnected,
  connecting,
  retrying,
  credentialsInvalid,
  connected,
  syncing,
  warning,
  error,
}

class SyncProvider extends ChangeNotifier {
  static const String logName = "SyncProvider";
  static const Duration _subscriptionSyncInterval = Duration(minutes: 30);
  static const Duration _episodeSyncInterval = Duration(minutes: 5);
  static const Duration _initialLoginDelay = Duration(seconds: 2);
  static const Duration _maxLoginDelay = Duration(minutes: 5);
  static const int _initialRetryAttempts = 5;
  static const int _episodeBatchSize = 30;
  static const int _maxSyncFailuresBeforeError = 3;

  final ISettingsRepository _settings;
  final SecureSettingsRepository _secureSettings;
  final ISyncRepository _syncRepository;

  SubscriptionProvider? _subscriptionProvider;
  HistoryProvider? _historyProvider;

  GpodderClient? _client;
  Timer? _subscriptionSyncTimer;
  Timer? _episodeSyncTimer;
  bool _isSyncingSubscriptions = false;
  bool _isSyncingEpisodes = false;
  bool _timersStarted = false;
  bool _syncEnabled = false;
  bool get isSyncEnabled => _syncEnabled;
  int _subscriptionSyncFailures = 0;
  int _episodeSyncFailures = 0;

  bool get isLoading =>
      _status == SyncStatus.connecting ||
      _status == SyncStatus.retrying ||
      _status == SyncStatus.syncing ||
      _isSyncingSubscriptions ||
      _isSyncingEpisodes;

  SyncStatus _status = SyncStatus.disconnected;
  SyncStatus get status => _status;

  String? _statusDescription;
  String? get statusDescription => _statusDescription;

  bool _statusIsError = false;
  bool get statusIsError => _statusIsError;

  bool _statusIsWarning = false;
  bool get statusIsWarning => _statusIsWarning;

  bool get hasEscalatedFailure => _status == SyncStatus.error;

  bool get isConfigured =>
      _status == SyncStatus.connected ||
      _status == SyncStatus.syncing ||
      _status == SyncStatus.warning ||
      _status == SyncStatus.error;

  DateTime? _lastSyncTimeCache;
  DateTime? get lastSyncTime => _lastSyncTimeCache;

  String? _serverUrl;
  String get serverUrl => _serverUrl ?? '';

  String? _username;
  String get username => _username ?? '';

  String? _deviceName;
  String get deviceName => _deviceName ?? 'Poddr';

  String? _deviceId;
  String get deviceId => _deviceId ?? '';

  List<Map<String, dynamic>>? _devices;
  List<Map<String, dynamic>>? get devices => _devices;

  Map<String, dynamic>? _syncGroups;
  Map<String, dynamic>? get syncGroups => _syncGroups;

  String _syncDeviceCaption = '';
  String get syncDeviceCaption => _syncDeviceCaption;

  String? _targetSyncDeviceId;
  String? get targetSyncDeviceId => _targetSyncDeviceId;

  String? _targetSyncDeviceName;
  String get targetSyncDeviceName => _targetSyncDeviceName ?? '';

  Future<bool>? _loginFuture;

  SyncProvider({
    ISettingsRepository? settings,
    SecureSettingsRepository? secureSettings,
    ISyncRepository? syncRepository,
  })  : _settings = settings ?? SharedPrefSettingsRepository(),
        _secureSettings = secureSettings ?? SecureSettingsRepository(),
        _syncRepository = syncRepository ?? DriftSyncRepository() {
    _init();
  }

  void update(SubscriptionProvider? subscriptionProvider,
      HistoryProvider? historyProvider) {
    _subscriptionProvider = subscriptionProvider;
    _historyProvider = historyProvider;
  }

  Future<void> _init() async {
    _syncEnabled = await _settings.getSyncEnabled();
    if (!_syncEnabled) return;

    await _setupClient();
    _loginAndSyncClient();
  }

  Future<void> _refreshLastSyncTime() async {
    final subTimestamp = await _settings.getSyncLastSubscriptionSync();
    final epTimestamp = await _settings.getSyncLastEpisodeSync();

    final timestamps =
        <int>[subTimestamp, epTimestamp].where((t) => t != 0).toList();
    if (timestamps.isEmpty) {
      _lastSyncTimeCache = null;
      return;
    }

    final latest = timestamps.reduce((a, b) => a > b ? a : b);
    _lastSyncTimeCache = DateTime.fromMillisecondsSinceEpoch(latest * 1000);
  }

  Future<void> _setupClient() async {
    _serverUrl = await _secureSettings.getSyncServerUrl();
    _username = await _secureSettings.getSyncUsername();
    final password = await _secureSettings.getSyncPassword();

    if (_serverUrl!.isEmpty || _username!.isEmpty || password.isEmpty) return;

    _deviceId = await _settings.getSyncDeviceId();
    if (_deviceId!.isEmpty) {
      _deviceId = generateUuidV4();
      await _settings.setSyncDeviceId(_deviceId!);
    }

    _deviceName = await _settings.getSyncDeviceName();
    if (deviceName.isEmpty) {
      _deviceName = 'Poddr';
      await _settings.setSyncDeviceName(_deviceName!);
    }

    _client?.dispose();
    _client = GpodderClient(
      serverUrl: serverUrl,
      username: username,
      password: password,
      deviceId: deviceId,
      deviceName: deviceName,
    );
  }

  Future<void> _loginAndSyncClient() async {
    if (_client == null) return;
    _updateStatus(SyncStatus.connecting, 'Connecting to sync server...');

    try {
      final success = await _loginWithRetry();
      if (success) {
        await _settings.setSyncEnabled(true);
        await _client!.registerDevice();
        _startTimers();
        await syncAll();
        await loadDevices();
      }
    } catch (e) {
      _updateStatus(SyncStatus.disconnected);
      error('Failed to configure sync', name: logName);
      debug('Configure sync failed: $e', name: logName);
    } finally {
      notifyListeners();
    }
  }

  void _updateStatus(SyncStatus status,
      [String? description, bool isError = false]) {
    _status = status;
    _statusDescription = description;
    _statusIsError = isError ||
        status == SyncStatus.credentialsInvalid ||
        status == SyncStatus.error;
    _statusIsWarning = !_statusIsError &&
        (status == SyncStatus.retrying || status == SyncStatus.warning);
    notifyListeners();
  }

  void _recordSyncOutcome({
    bool? subscriptionSuccess,
    bool? episodeSuccess,
  }) {
    if (subscriptionSuccess != null) {
      _subscriptionSyncFailures =
          subscriptionSuccess ? 0 : _subscriptionSyncFailures + 1;
    }
    if (episodeSuccess != null) {
      _episodeSyncFailures = episodeSuccess ? 0 : _episodeSyncFailures + 1;
    }
    _refreshSyncStatus();
  }

  void _refreshSyncStatus() {
    if (_status == SyncStatus.credentialsInvalid) return;

    final failures = _subscriptionSyncFailures > _episodeSyncFailures
        ? _subscriptionSyncFailures
        : _episodeSyncFailures;

    if (failures == 0) {
      _updateStatus(SyncStatus.connected);
      return;
    }

    final shouldEscalate = failures >= _maxSyncFailuresBeforeError;
    _updateStatus(
      shouldEscalate ? SyncStatus.error : SyncStatus.warning,
      shouldEscalate
          ? 'Sync is failing repeatedly. Check your connection.'
          : 'Some sync tasks failed. Will retry automatically.',
    );
  }

  Future<bool> _loginWithRetry() async {
    if (_client == null) return false;

    if (!_syncEnabled) return false;

    if (_loginFuture != null) {
      debug('Login already in progress, awaiting existing future...',
          name: logName);
      return await _loginFuture!;
    }

    _loginFuture = _performLoginWithRetry();
    try {
      return await _loginFuture!;
    } finally {
      _loginFuture = null;
    }
  }

  Future<bool> _performLoginWithRetry() async {
    Duration delay = _initialLoginDelay;

    for (int attempt = 0;; attempt++) {
      if (!_syncEnabled) {
        _updateStatus(SyncStatus.disconnected);
        return false;
      }

      try {
        final success = await _client!.login();
        if (success) {
          info(
              'Login successful after $attempt attempt${attempt == 1 ? '' : 's'}',
              name: logName);
          return true;
        }
      } on UnauthorizedException {
        _updateStatus(SyncStatus.credentialsInvalid);
        warning('Login failed: invalid credentials', name: logName);
        return false;
      } on NetworkException catch (e) {
        debug('Login attempt failed (network), will retry: $e', name: logName);
      } on ServerErrorException catch (e) {
        debug('Login attempt failed (server ${e.statusCode}), will retry: $e',
            name: logName);
      } catch (e) {
        debug('Login attempt failed, will retry: $e', name: logName);
      }

      if (attempt >= _initialRetryAttempts && attempt % 5 == 0) {
        _updateStatus(
            SyncStatus.retrying, 'Retrying in ${delay.inSeconds}s...');
      } else if (_status != SyncStatus.retrying) {
        _updateStatus(SyncStatus.retrying);
      }

      if (!delay.isNegative) {
        await Future.delayed(delay);
        delay = delay * 2;
        if (delay > _maxLoginDelay) delay = _maxLoginDelay;
      }
    }
  }

  Future<T?> _executeWithAuthRetry<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on UnauthorizedException {
      debug('Operation unauthorized, attempting re-login...', name: logName);
      final loginSuccess = await _loginWithRetry();
      if (loginSuccess) {
        try {
          return await operation();
        } catch (e, stackTrace) {
          error('Operation failed again after login',
              name: logName, error: e, stackTrace: stackTrace);
          return null;
        }
      }
      _updateStatus(SyncStatus.credentialsInvalid);
      return null;
    } catch (e, stackTrace) {
      error('Operation failed',
          name: logName, error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> loadDevices({bool forceRefresh = false}) async {
    try {
      if (forceRefresh || _devices == null || _syncGroups == null) {
        _devices = await _executeWithAuthRetry(() => _client!.getDevices());
        _syncGroups =
            await _executeWithAuthRetry(() => _client!.getSyncDevices());
      }

      if (_devices != null && _syncGroups != null) {
        final currentDeviceId = await _settings.getSyncDeviceId();
        final groups = _syncGroups!['synchronized'] as List? ?? [];
        String? syncDeviceId;

        for (final group in groups) {
          if (group is List) {
            for (final id in group) {
              if (id != currentDeviceId) {
                syncDeviceId = id as String;
                break;
              }
            }
          }
          if (syncDeviceId != null) break;
        }

        if (syncDeviceId != null && _devices != null) {
          final device = _devices!.firstWhere(
            (d) => d['id'] == syncDeviceId,
            orElse: () => {},
          );
          _targetSyncDeviceId = syncDeviceId;
          _targetSyncDeviceName = device['caption'] ?? syncDeviceId;
          _syncDeviceCaption = _targetSyncDeviceName!;
        } else {
          _targetSyncDeviceId = null;
          _targetSyncDeviceName = null;
          _syncDeviceCaption = '';
        }
      }
    } catch (e) {
      error('Failed to load devices', name: logName);
      debug('Load devices detail: $e', name: logName);
    } finally {
      notifyListeners();
    }
  }

  Future<void> connect({
    required String serverUrl,
    required String username,
    required String password,
    required String deviceName,
  }) async {
    if (serverUrl.isEmpty || username.isEmpty || password.isEmpty) {
      _updateStatus(
          SyncStatus.disconnected, 'Please fill in all required fields', true);
      return;
    }

    if (!isValidUrl(serverUrl, requireHttps: true)) {
      _updateStatus(
          SyncStatus.disconnected, 'Sync server must use HTTPS', true);
      return;
    }

    await configure(
      serverUrl: serverUrl,
      username: username,
      password: password,
      deviceName: deviceName,
    );
  }

  Future<void> configure({
    required String serverUrl,
    required String username,
    required String password,
    required String deviceName,
  }) async {
    try {
      await _secureSettings.setSyncServerUrl(serverUrl);
      await _secureSettings.setSyncUsername(username);
      await _secureSettings.setSyncPassword(password);
      _syncEnabled = true;

      await _setupClient();

      await _loginAndSyncClient();
    } catch (e) {
      _updateStatus(
          SyncStatus.disconnected, 'Failed to configure sync: $e', true);
      error('Failed to configure sync', name: logName);
      debug('Configure sync detail: $e', name: logName);
    }
  }

  void _startTimers() {
    if (_timersStarted) return;
    _timersStarted = true;

    _subscriptionSyncTimer?.cancel();
    _subscriptionSyncTimer =
        Timer.periodic(_subscriptionSyncInterval, (_) async {
      if (_isSyncingSubscriptions) return;
      final success = await syncSubscriptions();
      _recordSyncOutcome(subscriptionSuccess: success);
    });

    _episodeSyncTimer?.cancel();
    _episodeSyncTimer = Timer.periodic(_episodeSyncInterval, (_) async {
      if (_isSyncingEpisodes) return;
      final success = await syncEpisodes();
      _recordSyncOutcome(episodeSuccess: success);
    });
  }

  Future<void> _stopTimers() async {
    _subscriptionSyncTimer?.cancel();
    _subscriptionSyncTimer = null;
    _episodeSyncTimer?.cancel();
    _episodeSyncTimer = null;
    _timersStarted = false;
    notifyListeners();
  }

  Future<bool> syncAll() async {
    _updateStatus(SyncStatus.syncing);

    final results = await Future.wait([
      syncSubscriptions(),
      syncEpisodes(),
    ]);
    final subscriptionSuccess = results[0];
    final episodeSuccess = results[1];
    final success = subscriptionSuccess && episodeSuccess;

    await _refreshLastSyncTime();
    _recordSyncOutcome(
      subscriptionSuccess: subscriptionSuccess,
      episodeSuccess: episodeSuccess,
    );

    return success;
  }

  Future<bool> syncSubscriptions() async {
    if (_isSyncingSubscriptions ||
        _client == null ||
        _subscriptionProvider == null) {
      return true;
    }
    _isSyncingSubscriptions = true;
    var success = false;
    try {
      final result = await _executeWithAuthRetry(() async {
        final lastSync = await _settings.getSyncLastSubscriptionSync();

        if (lastSync == 0) {
          return await _performFullSubscriptionSync();
        }
        return await _performDeltaSubscriptionSync(lastSync);
      });
      success = result == true;
    } catch (e, stackTrace) {
      error('Subscription sync failed',
          name: logName, error: e, stackTrace: stackTrace);
    } finally {
      _isSyncingSubscriptions = false;
      notifyListeners();
    }
    return success;
  }

  Future<bool> _performFullSubscriptionSync() async {
    final serverUrls = await _client!.getAllSubscriptions();
    final localSubscriptions = _subscriptionProvider?.subscriptions ?? [];
    final localUrls = localSubscriptions
        .map((s) => s.rss ?? '')
        .where((url) => url.isNotEmpty)
        .toSet();

    var remoteApplySucceeded = true;
    for (final url in serverUrls) {
      if (!localUrls.contains(url)) {
        final added = await _subscriptionProvider?.addSubscription(
              rss: url,
              fromSync: true,
            ) ??
            false;
        if (added) {
          localUrls.add(url);
        } else {
          remoteApplySucceeded = false;
          warning('Failed to apply remote subscription $url', name: logName);
        }
      }
    }

    if (!remoteApplySucceeded) return false;

    final localOnly =
        localUrls.where((url) => !serverUrls.contains(url)).toList();
    if (localOnly.isNotEmpty) {
      for (final url in localOnly) {
        await _syncRepository.addPendingSubscriptionAction(url, 'add');
      }
      await _client!
          .uploadSubscriptionChanges(add: localOnly.toList(), remove: []);
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _settings.setSyncLastSubscriptionSync(now);
    await _refreshLastSyncTime();
    await _syncRepository.clearPendingSubscriptionActions();
    return true;
  }

  Future<bool> _performDeltaSubscriptionSync(int lastSync) async {
    final changes = await _client!.getSubscriptionChanges(since: lastSync);

    final localSubscriptions = _subscriptionProvider?.subscriptions ?? [];
    final localUrls = localSubscriptions
        .map((s) => s.rss ?? '')
        .where((url) => url.isNotEmpty)
        .toSet();

    final remoteAdd = List<String>.from(changes['add'] ?? []);
    final remoteRemove = List<String>.from(changes['remove'] ?? []);
    final remoteTimestamp =
        changes['timestamp'] ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);

    final actionMap = <String, Map<String, dynamic>>{};

    for (final url in remoteAdd) {
      actionMap[url] = {
        'action': 'add',
        'timestamp': remoteTimestamp,
        'source': 'remote',
      };
    }
    for (final url in remoteRemove) {
      final existing = actionMap[url];
      if (existing == null ||
          remoteTimestamp > (existing['timestamp'] as int)) {
        actionMap[url] = {
          'action': 'remove',
          'timestamp': remoteTimestamp,
          'source': 'remote',
        };
      }
    }

    final pendingChanges =
        await _syncRepository.getPendingSubscriptionActions();
    for (final pending in pendingChanges) {
      final url = pending['rss'] as String;
      final action = pending['action'] as String;
      final timestamp = pending['timestamp'] as int;
      final existing = actionMap[url];
      if (existing == null || timestamp > (existing['timestamp'] as int)) {
        actionMap[url] = {
          'action': action,
          'timestamp': timestamp,
          'source': 'local',
        };
      }
    }

    var remoteApplySucceeded = true;
    for (final entry in actionMap.entries) {
      final url = entry.key;
      final actionData = entry.value;
      final action = actionData['action'] as String;

      if (action == 'add' && !localUrls.contains(url)) {
        final added = await _subscriptionProvider?.addSubscription(
              rss: url,
              fromSync: true,
            ) ??
            false;
        if (added) {
          localUrls.add(url);
        } else {
          remoteApplySucceeded = false;
          warning('Failed to apply remote subscription add $url',
              name: logName);
        }
      } else if (action == 'remove' && localUrls.contains(url)) {
        final removed = await _subscriptionProvider?.removeSubscription(
              url,
              fromSync: true,
            ) ??
            false;
        if (removed) {
          localUrls.remove(url);
        } else {
          remoteApplySucceeded = false;
          warning('Failed to apply remote subscription remove $url',
              name: logName);
        }
      }
    }

    if (!remoteApplySucceeded) return false;

    final localPendingToUpload = <Map<String, dynamic>>[];
    for (final pending in pendingChanges) {
      final url = pending['rss'] as String;
      final action = pending['action'] as String;
      final timestamp = pending['timestamp'] as int;
      final surviving = actionMap[url];
      if (surviving != null &&
          surviving['action'] == action &&
          surviving['timestamp'] == timestamp) {
        localPendingToUpload.add(pending);
      }
    }

    final addsToUpload = localPendingToUpload
        .where((a) => a['action'] == 'add')
        .map((a) => a['rss'] as String)
        .toList();
    final removesToUpload = localPendingToUpload
        .where((a) => a['action'] == 'remove')
        .map((a) => a['rss'] as String)
        .toList();

    if (addsToUpload.isNotEmpty || removesToUpload.isNotEmpty) {
      final uploadResult = await _client!.uploadSubscriptionChanges(
          add: addsToUpload, remove: removesToUpload);
      final newTimestamp = uploadResult['timestamp'] ??
          (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      await _settings.setSyncLastSubscriptionSync(newTimestamp);
      await _refreshLastSyncTime();
    } else {
      await _settings.setSyncLastSubscriptionSync(remoteTimestamp);
    }

    await _syncRepository.clearPendingSubscriptionActions();
    return true;
  }

  Future<bool> syncEpisodes() async {
    if (_isSyncingEpisodes || _client == null || _historyProvider == null) {
      return true;
    }
    _isSyncingEpisodes = true;
    var success = false;
    try {
      final result = await _executeWithAuthRetry(() async {
        final lastSync = await _settings.getSyncLastEpisodeSync();

        final serverActions = await _client!.getEpisodeActions(since: lastSync);
        final actions = serverActions['actions'] as List?;

        if (actions != null) {
          await _fetchAndApplyRemoteHistory(actions);
        }

        final localActions = await _syncRepository.getPendingEpisodeActions();
        if (localActions.isNotEmpty) {
          const batchSize = _episodeBatchSize;
          int lastTimestamp = lastSync;
          for (var i = 0; i < localActions.length; i += batchSize) {
            final end =
                (i + batchSize < localActions.length) ? i + batchSize : null;
            final batch = localActions.sublist(i, end);
            final result = await _client!.uploadEpisodeActions(batch);
            lastTimestamp = result['timestamp'] ?? lastTimestamp;
            await _syncRepository.deletePendingEpisodeActions(
                batch.map((a) => a['id'] as int).toList());
          }
          await _settings.setSyncLastEpisodeSync(lastTimestamp);
          await _refreshLastSyncTime();
        }
        return true;
      });
      success = result == true;
    } catch (e, stackTrace) {
      error('Episode sync failed',
          name: logName, error: e, stackTrace: stackTrace);
    } finally {
      _isSyncingEpisodes = false;
      notifyListeners();
    }
    return success;
  }

  int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      try {
        return DateTime.parse(value).toUtc().millisecondsSinceEpoch ~/ 1000;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _applyEpisodeActionToHistory(
      String episodeUrl, String actionType, int position, int duration) async {
    if (actionType == 'play') {
      final episode = _subscriptionProvider?.findEpisodeByUrl(episodeUrl);
      await _historyProvider?.applyRemoteProgress(
        audioUrl: episodeUrl,
        position: position,
        duration: duration,
        episode: episode,
      );
    } else if (actionType == 'new') {
      await _historyProvider?.removeHistory(episodeUrl);
    }
  }

  Future<void> _fetchAndApplyRemoteHistory(List<dynamic> actions) async {
    debug("Applying remote episode actions", name: logName);

    final remoteHistory = <String, Map<String, dynamic>>{};

    for (final action in actions) {
      final episodeUrl = action['episode'] as String?;
      final actionType = action['action'] as String?;
      final position = _parseIntSafely(action['position']) ?? 0;
      final duration = _parseIntSafely(action['total']) ?? 0;
      final timestamp = _parseIntSafely(action['timestamp']) ?? 0;

      if (episodeUrl == null) continue;

      if (!remoteHistory.containsKey(episodeUrl) ||
          (remoteHistory[episodeUrl]!['timestamp'] as int) < timestamp) {
        remoteHistory[episodeUrl] = {
          'position': position,
          'duration': duration,
          'action': actionType,
          'timestamp': timestamp,
        };
      }
    }

    for (final entry in remoteHistory.entries) {
      final episodeUrl = entry.key;
      final data = entry.value;
      final actionType = data['action'] as String?;
      final position = data['position'] as int? ?? 0;
      final duration = data['duration'] as int? ?? 0;
      await _applyEpisodeActionToHistory(
          episodeUrl, actionType ?? '', position, duration);
    }
  }

  Future<void> recordEpisodeAction({
    required String podcastRss,
    required String episodeUrl,
    required String action,
    int position = 0,
  }) async {
    if (!_syncEnabled) return;
    debug(
        "Recording episode action: $action for $episodeUrl at position $position",
        name: logName);

    try {
      await _syncRepository.addPendingEpisodeAction(
        podcastRss: podcastRss,
        episodeUrl: episodeUrl,
        action: action,
        position: position,
        timestamp: DateTime.now().toUtc(),
      );
    } catch (e) {
      warning('Failed to queue episode action: $e', name: logName);
    }
  }

  Future<List<Map<String, dynamic>>?> getDevices() async {
    return _client?.getDevices();
  }

  Future<Map<String, dynamic>?> getSyncDevices() async {
    return _client?.getSyncDevices();
  }

  Future<bool> setSyncDevice(String targetDeviceId) async {
    if (_client == null || _syncGroups == null) return false;
    final currentDeviceId = await _settings.getSyncDeviceId();

    final synchronized = _syncGroups!['synchronized'] as List? ?? [];

    List<String>? targetGroup;
    for (final group in synchronized) {
      if (group is List) {
        final groupIds = group.map((id) => id.toString()).toList();
        if (groupIds.contains(targetDeviceId)) {
          targetGroup = groupIds;
          break;
        }
      }
    }

    final newSynchronized = <List<String>>[];

    if (targetGroup != null && !targetGroup.contains(currentDeviceId)) {
      newSynchronized.add([...targetGroup, currentDeviceId]);
    } else if (targetGroup == null && targetDeviceId.isNotEmpty) {
      newSynchronized.add([targetDeviceId, currentDeviceId]);
    } else {
      return true;
    }

    final success = await _client!.updateSyncDevices(
      synchronized: newSynchronized,
      notSynchronized: <String>[],
    );

    if (success) {
      await loadDevices(forceRefresh: true);
    }

    return success;
  }

  Future<bool> clearSyncDevice() async {
    if (_client == null || _syncGroups == null) return false;
    final currentDeviceId = await _settings.getSyncDeviceId();

    final synchronized = _syncGroups!['synchronized'] as List? ?? [];

    List<String>? currentGroup;
    for (final group in synchronized) {
      if (group is List) {
        final groupIds = group.map((id) => id.toString()).toList();
        if (groupIds.contains(currentDeviceId)) {
          currentGroup = groupIds;
          break;
        }
      }
    }

    if (currentGroup == null) return true;

    final newSynchronized = <List<String>>[];
    final newNotSynchronized = <String>[currentDeviceId];

    final remainingGroup =
        currentGroup.where((id) => id != currentDeviceId).toList();
    if (remainingGroup.length > 1) {
      newSynchronized.add(remainingGroup);
    }

    final success = await _client!.updateSyncDevices(
      synchronized: newSynchronized,
      notSynchronized: newNotSynchronized,
    );

    if (success) {
      await loadDevices(forceRefresh: true);
    }

    return success;
  }

  Future<void> disconnectUi() async {
    await disconnect();

    _syncDeviceCaption = '';
    _devices = null;
    _syncGroups = null;
    _updateStatus(SyncStatus.disconnected, 'Disconnected from sync server');
  }

  Future<void> disconnect() async {
    _syncEnabled = false;
    await _syncRepository.clearPendingSubscriptionActions();
    await _syncRepository.clearPendingEpisodeActions();
    await _stopTimers();
    await _client?.logout();
    _client?.dispose();
    _client = null;
    await _settings.setSyncEnabled(false);
    await _secureSettings.clearSyncPassword();
  }

  Future<void> syncNow() async {
    await syncAll();
  }

  Future<void> fullResync() async {
    if (_client == null) return;
    _updateStatus(SyncStatus.syncing, 'Full re-sync in progress...');

    try {
      await _settings.setSyncLastSubscriptionSync(0);
      await _settings.setSyncLastEpisodeSync(0);
      await _syncRepository.clearPendingSubscriptionActions();
      await _syncRepository.clearPendingEpisodeActions();
      await syncAll();
    } catch (e, stackTrace) {
      error('Full re-sync failed',
          name: logName, error: e, stackTrace: stackTrace);
      if (_status != SyncStatus.credentialsInvalid) {
        _updateStatus(
          SyncStatus.error,
          'Full re-sync failed. Please try again.',
        );
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> selectSyncDevice(String targetDeviceId) async {
    bool success;
    if (targetDeviceId.isEmpty) {
      success = await clearSyncDevice();
    } else {
      success = await setSyncDevice(targetDeviceId);
    }

    _updateStatus(
      SyncStatus.connected,
      success ? 'Sync device updated' : 'Failed to update sync device',
      !success,
    );

    if (success) {
      await loadDevices();
    }
  }

  @override
  void dispose() {
    _subscriptionSyncTimer?.cancel();
    _subscriptionSyncTimer = null;
    _episodeSyncTimer?.cancel();
    _episodeSyncTimer = null;
    _timersStarted = false;
    _client?.dispose();
    super.dispose();
  }
}
