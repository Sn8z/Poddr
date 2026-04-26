import 'package:flutter/widgets.dart';
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
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    );
  }
}
