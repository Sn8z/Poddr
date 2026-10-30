import 'package:flutter/widgets.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/services/opml.dart';
import 'package:poddr/services/subscriptions.dart';

class OpmlViewModel extends ChangeNotifier {
  static const String logName = "OpmlViewModel";

  final OpmlService _opmlService = OpmlService();
  final SubscriptionProvider _subscriptionProvider;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  bool _isError = false;
  bool get isError => _isError;

  String? _lastError;
  String? get lastError => _lastError;

  double? _importProgress;
  double? get importProgress => _importProgress;

  List<String> _pendingUrls = [];
  int _pendingSkipped = 0;
  int? get pendingNewCount => _pendingUrls.isEmpty ? null : _pendingUrls.length;
  int get pendingSkippedCount => _pendingSkipped;

  bool _cancelImport = false;

  OpmlViewModel(this._subscriptionProvider);

  Future<bool> prepareImport() async {
    _cancelImport = false;
    _importProgress = null;
    _pendingUrls = [];
    _pendingSkipped = 0;
    _setLoading(true);
    _setStatus('Selecting file...');

    try {
      final preview = await _opmlService.pickAndParse(
        _subscriptionProvider.subscriptions,
      );
      if (preview == null) {
        _setStatus(null);
        return false;
      }
      if (preview.stopMessage != null) {
        _setStatus(preview.stopMessage, isError: preview.isError);
        return false;
      }
      _pendingUrls = preview.newUrls;
      _pendingSkipped = preview.skippedCount;
      _setStatus('${preview.newUrls.length} new feeds found');
      return true;
    } catch (e, stackTrace) {
      error('Failed to prepare OPML import',
          name: logName, error: e, stackTrace: stackTrace);
      _setStatus(
        'The OPML file could not be read. Please try again.',
        isError: true,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> runPendingImport() async {
    final urls = _pendingUrls;
    _pendingUrls = [];
    _pendingSkipped = 0;
    if (urls.isEmpty) {
      _setStatus(null);
      return false;
    }
    _setLoading(true);

    var success = false;
    try {
      final result = await _opmlService.importUrls(
        urls,
        (rss) => _subscriptionProvider.addSubscriptionSilent(rss: rss),
        onProgress: (done, total) {
          _importProgress = total == 0 ? null : done / total;
          _setStatus('Importing $done of $total…');
        },
        isCancelled: () => _cancelImport,
      );
      success = !result.isError;
      _setStatus(result.message, isError: result.isError);
    } catch (e, stackTrace) {
      error('Failed to import OPML feeds',
          name: logName, error: e, stackTrace: stackTrace);
      _setStatus(
        'The import could not be completed. Please try again.',
        isError: true,
      );
    } finally {
      _importProgress = null;
      _setLoading(false);
    }

    try {
      await _subscriptionProvider.refresh(force: true);
    } catch (e, stackTrace) {
      error('Failed to refresh subscriptions after import',
          name: logName, error: e, stackTrace: stackTrace);
    }
    return success;
  }

  void dismissPendingImport() {
    _pendingUrls = [];
    _pendingSkipped = 0;
    _setStatus(null);
  }

  void cancelImport() {
    _cancelImport = true;
  }

  Future<bool> exportOpml() async {
    _setLoading(true);
    _setStatus('Generating OPML...');

    try {
      final result = await _opmlService.exportOpml(
        _subscriptionProvider.subscriptions,
      );
      if (result.message == null) {
        _setStatus(null);
        return false;
      }
      _setStatus(result.message, isError: result.isError);
      return !result.isError;
    } catch (e, stackTrace) {
      error('Failed to export OPML',
          name: logName, error: e, stackTrace: stackTrace);
      _setStatus(
        'The OPML file could not be exported. Please try again.',
        isError: true,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setStatus(String? message, {bool isError = false}) {
    _statusMessage = message;
    _isError = isError;
    _lastError = isError ? message : null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
