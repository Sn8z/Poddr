import 'package:flutter/widgets.dart';
import 'package:poddr/services/opml.dart';
import 'package:poddr/services/subscriptions.dart';

class OpmlViewModel extends ChangeNotifier {
  final OpmlService _opmlService = OpmlService();
  final SubscriptionProvider _subscriptionProvider;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  double? _importProgress;
  double? get importProgress => _importProgress;

  List<String> _pendingUrls = [];
  int _pendingSkipped = 0;
  int? get pendingNewCount =>
      _pendingUrls.isEmpty ? null : _pendingUrls.length;
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
        _setStatus(preview.stopMessage);
        return false;
      }
      _pendingUrls = preview.newUrls;
      _pendingSkipped = preview.skippedCount;
      _setStatus('${preview.newUrls.length} new feeds found');
      return true;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> runPendingImport() async {
    final urls = _pendingUrls;
    _pendingUrls = [];
    _pendingSkipped = 0;
    if (urls.isEmpty) {
      _setStatus(null);
      return;
    }
    _setLoading(true);

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
      _setStatus(result);
    } finally {
      _importProgress = null;
      _setLoading(false);
    }

    await _subscriptionProvider.refresh(force: true);
  }

  void dismissPendingImport() {
    _pendingUrls = [];
    _pendingSkipped = 0;
    _setStatus(null);
  }

  void cancelImport() {
    _cancelImport = true;
  }

  Future<void> exportOpml() async {
    _setLoading(true);
    _setStatus('Generating OPML...');

    try {
      final result = await _opmlService.exportOpml(
        _subscriptionProvider.subscriptions,
      );
      _setStatus(result);
    } finally {
      _setLoading(false);
    }
  }

  void _setStatus(String? message) {
    _statusMessage = message;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
