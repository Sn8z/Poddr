import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:poddr/providers/media.dart';

class EpisodeTitle extends StatelessWidget {
  const EpisodeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    String? title =
        context.select<MediaProvider, String?>((e) => e.mediaItem.value?.title);

    return Text(
      title ?? "Title",
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
