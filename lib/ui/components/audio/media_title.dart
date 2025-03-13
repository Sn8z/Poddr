import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media.dart';

class MediaTitle extends StatelessWidget {
  const MediaTitle({super.key});

  @override
  Widget build(BuildContext context) {
    String? artist = context
        .select<MediaProvider, String?>((e) => e.mediaItem.value?.artist);
    String? podcastRSS = context.select<MediaProvider, String?>(
        (e) => e.mediaItem.value?.extras?["podcastRSS"]);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (podcastRSS != null) {
            context.go("/podcasts/details?rss=$podcastRSS");
          }
        },
        child: Text(
          artist ?? "Artist",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
