import 'package:flutter/widgets.dart';
import 'package:poddr/models/collection.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/components/widgets/poddr_toggle.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:provider/provider.dart';

class PoddrCollectionFilterList extends StatelessWidget {
  final Set<int> selectedCollectionIds;
  final ValueChanged<Set<int>> onCollectionChanged;

  const PoddrCollectionFilterList({
    super.key,
    required this.selectedCollectionIds,
    required this.onCollectionChanged,
  });

  void _toggleCollection(int collectionId) {
    final ids = Set<int>.from(selectedCollectionIds);
    if (ids.contains(collectionId)) {
      ids.remove(collectionId);
    } else {
      ids.add(collectionId);
    }
    onCollectionChanged(ids);
  }

  @override
  Widget build(BuildContext context) {
    final collectionsProvider = context.read<CollectionsProvider>();

    return StreamBuilder<List<PodcastCollection>>(
      stream: collectionsProvider.collectionsStream,
      builder: (context, snapshot) {
        final collections = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var collection in collections)
              PoddrToggle(
                label: collection.name,
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(collection.color),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                value: selectedCollectionIds.contains(collection.id),
                onChanged: (value) {
                  _toggleCollection(collection.id);
                },
              ),
            gapH8,
            PoddrOutlinedButton(
              onPressed: selectedCollectionIds.isEmpty
                  ? null
                  : () => onCollectionChanged({}),
              child: const Text("Clear all"),
            ),
          ],
        );
      },
    );
  }
}
