import 'package:flutter/widgets.dart';
import 'package:poddr/models/collection.dart';
import 'package:poddr/ui/components/widgets/collection_chip.dart';

class PoddrCollectionsDisplay extends StatelessWidget {
  const PoddrCollectionsDisplay({super.key, required this.collections});
  final List<PodcastCollection> collections;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: collections
          .map((c) => PoddrCollectionChip(collection: c))
          .toList(),
    );
  }
}
