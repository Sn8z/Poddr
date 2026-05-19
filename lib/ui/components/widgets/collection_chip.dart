import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/models/collection.dart';

class PoddrCollectionChip extends StatelessWidget {
  const PoddrCollectionChip({super.key, required this.collection});
  final PodcastCollection collection;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(collection.color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        collection.name,
        style: context.theme.textTheme.labelMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: context.theme.onPrimary,
        ),
      ),
    );
  }
}
