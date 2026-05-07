import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:poddr/core/log.dart';
import 'package:uuid/uuid.dart';
import 'package:poddr/data/settings/settings_repository.dart';
import 'package:poddr/data/settings/secure_settings_repository.dart';
import 'package:poddr/data/settings/prefs_settings_repository.dart';
import 'package:poddr/data/sync/gpodder_client.dart';
import 'package:poddr/data/sync/sync_repository.dart';
import 'package:poddr/data/sync/drift_sync_repository.dart';
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/services/history.dart';

class SyncProvider extends ChangeNotifier {
  static const String logName = "SyncProvider";
  static const Duration _subscriptionSyncInterval = Duration(minutes: 30);
  static const Duration _episodeSyncInterval = Duration(minutes: 5);
  static const Duration _initialLoginDelay = Duration(seconds: 2);
  static const Duration _maxLoginDelay = Duration(minutes: 5);
  static const int _initialRetryAttempts = 5;
  static const int _episodeBatchSize = 30;

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

  bool get isLoading => _isSyncingSubscriptions || _isSyncingEpisodes;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  DateTime? _lastSyncTimeCache;
  DateTime? get lastSyncTime => _lastSyncTimeCache;

  bool _isConfigured = false;
  bool get isConfigured => _isConfigured;

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
    _serverUrl = await _settings.getSyncServerUrl();
    _username = await _settings.getSyncUsername();
    final password = await _secureSettings.getSyncPassword();

    if (serverUrl.isEmpty || username.isEmpty || password.isEmpty) return;

    _deviceId = await _settings.getSyncDeviceId();
    if (_deviceId!.isEmpty) {
      _deviceId = const Uuid().v4();
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
    _statusMessage = 'Connecting to sync server...';
    notifyListeners();

    try {
      final success = await _loginWithRetry();
      if (success) {
        await _client!.registerDevice();
        _startTimers();
        await syncAll();
        _isConfigured = true;
        _statusMessage = 'Connected to sync server';
        await loadDevices();
      } else {
        _isConfigured = false;
        _errorMessage =
            'Failed to connect to sync server after multiple attempts';
        error(_errorMessage!, name: logName);
      }
    } catch (e) {
      _isConfigured = false;
      _errorMessage = 'Failed to configure sync: $e';
      error(_errorMessage!, name: logName);
    } finally {
      notifyListeners();
    }
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
        debug('Sync disabled, stopping login attempts', name: logName);
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
        error('Login failed: Invalid credentials, stopping retry loop',
            name: logName);
        return false;
      } catch (e) {
        error('Login failed: ${e.toString()}, will retry', name: logName);
      }

      if (attempt >= _initialRetryAttempts && attempt % 5 == 0) {
        debug('Login failed, still retrying... (attempt $attempt)',
            name: logName);
        _errorMessage = 'Login failed, retrying in ${delay.inSeconds}s...';
        notifyListeners();
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
        } catch (e) {
          error('Operation failed again after login: $e', name: logName);
          return null;
        }
      }
      _errorMessage = 'Authentication failed during operation';
      notifyListeners();
      return null;
    } catch (e) {
      error('Operation failed: $e', name: logName);
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
      error('Failed to load devices: $e', name: logName);
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
      _statusMessage = 'Please fill in all required fields';
      notifyListeners();
      return;
    }

    _statusMessage = '';
    notifyListeners();

    await configure(
      serverUrl: serverUrl,
      username: username,
      password: password,
      deviceName: deviceName,
    );

    notifyListeners();
  }

  Future<void> configure({
    required String serverUrl,
    required String username,
    required String password,
    required String deviceName,
  }) async {
    try {
      await _settings.setSyncServerUrl(serverUrl);
      await _settings.setSyncUsername(username);
      await _settings.setSyncDeviceName(deviceName);
      await _secureSettings.setSyncPassword(password);
      await _settings.setSyncEnabled(true);
      _syncEnabled = true;

      await _setupClient();

      await _loginAndSyncClient();
    } catch (e) {
      _errorMessage = 'Failed to configure sync: $e';
      _isConfigured = false;
      error(_errorMessage!, name: logName);
    }
  }

  void _startTimers() {
    if (_timersStarted) return;
    _timersStarted = true;

    _subscriptionSyncTimer?.cancel();
    _subscriptionSyncTimer = Timer.periodic(_subscriptionSyncInterval, (_) {
      syncSubscriptions().catchError(
          (e) => error("Periodic sub sync failed: $e", name: logName));
    });

    _episodeSyncTimer?.cancel();
    _episodeSyncTimer = Timer.periodic(_episodeSyncInterval, (_) {
      syncEpisodes().catchError(
          (e) => error("Periodic episode sync failed: $e", name: logName));
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

  Future<void> syncAll() async {
    _statusMessage = 'Syncing subscriptions and episodes...';
    notifyListeners();

    await Future.wait([
      syncSubscriptions(),
      syncEpisodes(),
    ]);

    await _refreshLastSyncTime();
  }

  Future<void> syncSubscriptions() async {
    if (_isSyncingSubscriptions ||
        _client == null ||
        _subscriptionProvider == null) {
      return;
    }
    _isSyncingSubscriptions = true;
    notifyListeners();
    try {
      await _executeWithAuthRetry(() async {
        final lastSync = await _settings.getSyncLastSubscriptionSync();

        if (lastSync == 0) {
          await _performFullSubscriptionSync();
        } else {
          await _performDeltaSubscriptionSync(lastSync);
        }

        return true;
      });
    } catch (e) {
      _errorMessage = 'Subscription sync failed: $e';
      error(_errorMessage!, name: logName);
    } finally {
      _isSyncingSubscriptions = false;
      notifyListeners();
    }
  }

  Future<void> _performFullSubscriptionSync() async {
    final serverUrls = await _client!.getAllSubscriptions();
    final localSubscriptions = _subscriptionProvider?.subscriptions ?? [];
    final localUrls = localSubscriptions
        .map((s) => s.rss ?? '')
        .where((url) => url.isNotEmpty)
        .toSet();

    for (final url in serverUrls) {
      if (!localUrls.contains(url)) {
        await _subscriptionProvider?.addSubscription(rss: url, fromSync: true);
      }
    }

    final localOnly =
        localUrls.where((url) => !serverUrls.contains(url)).toList();
    for (final url in localOnly) {
      await _syncRepository.addPendingSubscriptionAction(url, 'add');
    }

    if (localOnly.isNotEmpty) {
      await _client!
          .uploadSubscriptionChanges(add: localOnly.toList(), remove: []);
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _settings.setSyncLastSubscriptionSync(now);
    await _refreshLastSyncTime();
    await _syncRepository.clearPendingSubscriptionActions();
  }

  Future<void> _performDeltaSubscriptionSync(int lastSync) async {
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

    for (final entry in actionMap.entries) {
      final url = entry.key;
      final actionData = entry.value;
      final action = actionData['action'] as String;

      if (action == 'add' && !localUrls.contains(url)) {
        await _subscriptionProvider?.addSubscription(rss: url, fromSync: true);
        localUrls.add(url);
      } else if (action == 'remove' && localUrls.contains(url)) {
        await _subscriptionProvider?.removeSubscription(url, fromSync: true);
        localUrls.remove(url);
      }
    }

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
  }

  Future<void> syncEpisodes() async {
    if (_isSyncingEpisodes || _client == null || _historyProvider == null) {
      return;
    }
    _isSyncingEpisodes = true;
    try {
      await _executeWithAuthRetry(() async {
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
    } catch (e) {
      _errorMessage = 'Episode sync failed: $e';
      error(_errorMessage!, name: logName);
    } finally {
      _isSyncingEpisodes = false;
      notifyListeners();
    }
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
      String episodeUrl, String actionType, int position) async {
    if (actionType == 'play') {
      await _historyProvider?.updateProgress(episodeUrl, position, 0);
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
      final timestamp = _parseIntSafely(action['timestamp']) ?? 0;

      if (episodeUrl == null) continue;

      if (!remoteHistory.containsKey(episodeUrl) ||
          (remoteHistory[episodeUrl]!['timestamp'] as int) < timestamp) {
        remoteHistory[episodeUrl] = {
          'position': position,
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
      await _applyEpisodeActionToHistory(
          episodeUrl, actionType ?? '', position);
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

    await _syncRepository.addPendingEpisodeAction(
      podcastRss: podcastRss,
      episodeUrl: episodeUrl,
      action: action,
      position: position,
      timestamp: DateTime.now().toUtc(),
    );
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
    _statusMessage = null;
    notifyListeners();

    await disconnect();

    _isConfigured = false;
    _errorMessage = null;
    _syncDeviceCaption = '';
    _devices = null;
    _syncGroups = null;
    _statusMessage = 'Disconnected from sync server';
    notifyListeners();
  }

  Future<void> disconnect() async {
    _syncEnabled = false;
    await _syncRepository.clearPendingSubscriptionActions();
    await _syncRepository.clearPendingEpisodeActions();
    await _stopTimers();
    await _client?.logout();
    _client = null;
    await _settings.setSyncEnabled(false);
    await _secureSettings.clearSyncPassword();
  }

  Future<void> syncNow() async {
    _statusMessage = '';
    _errorMessage = null;
    notifyListeners();

    await syncAll();

    _statusMessage = 'Last sync: ${_lastSyncTimeCache?.toLocal() ?? 'Never'}';
    notifyListeners();
  }

  Future<void> fullResync() async {
    if (_client == null) return;
    _statusMessage = 'Full re-sync in progress...';
    notifyListeners();

    try {
      await _executeWithAuthRetry(() async {
        await _settings.setSyncLastSubscriptionSync(0);
        await _settings.setSyncLastEpisodeSync(0);
        await _syncRepository.clearPendingSubscriptionActions();
        await _syncRepository.clearPendingEpisodeActions();
        await syncAll();
        _statusMessage = 'Full re-sync complete';
        return true;
      });
    } catch (e) {
      _errorMessage = 'Full re-sync failed: $e';
      error(_errorMessage!, name: logName);
    } finally {
      notifyListeners();
    }
  }

  Future<void> selectSyncDevice(String targetDeviceId) async {
    _statusMessage = '';
    _errorMessage = null;
    notifyListeners();

    bool success;
    if (targetDeviceId.isEmpty) {
      success = await clearSyncDevice();
    } else {
      success = await setSyncDevice(targetDeviceId);
    }

    _statusMessage =
        success ? 'Sync device updated' : 'Failed to update sync device';

    if (success) {
      await loadDevices();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimers();
    _client?.dispose();
    super.dispose();
  }
}
