import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:poddr/providers/media.dart';

class MediaTitle extends StatelessWidget {
  const MediaTitle({super.key});

  @override
  Widget build(BuildContext context) {
    String? artist = context
        .select<MediaProvider, String?>((e) => e.mediaItem.value?.artist);

    return Text(
      artist ?? "Artist",
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
