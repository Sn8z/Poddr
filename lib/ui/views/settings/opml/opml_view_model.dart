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

  OpmlViewModel(this._subscriptionProvider);

  Future<void> importOpml() async {
    _setLoading(true);
    _setStatus('Selecting file...');

    final result = await _opmlService.importOpml(
      _subscriptionProvider.subscriptions,
      (rss) => _subscriptionProvider.addSubscriptionSilent(rss: rss),
    );

    if (result.isNotEmpty) {
      _setStatus(result);
    } else {
      _setStatus(null);
    }

    _setLoading(false);

    await _subscriptionProvider.refresh();
  }

  Future<void> exportOpml() async {
    _setLoading(true);
    _setStatus('Generating OPML...');

    final result = await _opmlService.exportOpml(
      _subscriptionProvider.subscriptions,
    );

    if (result.isNotEmpty) {
      _setStatus(result);
    } else {
      _setStatus(null);
    }

    _setLoading(false);
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
