import 'package:flutter/widgets.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/ui/utils/colors.dart';

class CollectionsViewModel extends ChangeNotifier {
  final CollectionsProvider _collectionsProvider;

  final TextEditingController nameController = TextEditingController();
  int _newCollectionColor = generateRandomColorInt();

  CollectionsViewModel(this._collectionsProvider);

  String get newCollectionName => nameController.text;
  int get newCollectionColor => _newCollectionColor;
  String? get lastError => _collectionsProvider.lastError;

  void setNewCollectionColor(int value) {
    _newCollectionColor = value;
    notifyListeners();
  }

  Future<bool> submitNewCollection() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return false;

    final success = await createCollection(name, _newCollectionColor);
    if (success) {
      nameController.clear();
      _newCollectionColor = generateRandomColorInt();
      notifyListeners();
    }
    return success;
  }

  Future<bool> createCollection(String name, int color) {
    return _collectionsProvider.createCollection(name, color: color);
  }

  Future<bool> updateCollectionName(int id, String name) async {
    return await _collectionsProvider.updateCollectionName(id, name);
  }

  Future<bool> updateCollectionColor(int id, int color) async {
    return await _collectionsProvider.updateCollectionColor(id, color);
  }

  Future<bool> deleteCollection(int id) async {
    return await _collectionsProvider.deleteCollection(id);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
