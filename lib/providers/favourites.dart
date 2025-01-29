import 'dart:async';
import 'package:flutter/foundation.dart';

class FavouritesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _favourites = [];
  List<Map<String, dynamic>> get favourites => _favourites;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FavouritesProvider() {}

  void initStream() async {
    _setLoading(true);

    _setLoading(false);
  }

  Future<void> addFavourite({
    String? title,
    String? rss,
    String? description,
    String? author,
    String? image,
  }) async {
    try {
      //TODO
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
    } finally {
      debugPrint("Finished inserting favourite");
    }
  }

  Future<void> removeFavourite(int id) async {
    try {
      debugPrint("Removing favourite with id $id");
      //TODO
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
    } finally {
      debugPrint("Finished removing favourite");
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
