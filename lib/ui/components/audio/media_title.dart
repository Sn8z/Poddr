import 'package:flutter/material.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

class MediaTitle extends StatelessWidget {
  final double size;
  final Color? color;

  const MediaTitle({
    super.key,
    this.size = 12,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    String? artist =
        context.select<MediaProvider, String?>((e) => e.podcastTitle);
    String? rss = context.select<MediaProvider, String?>((e) => e.podcastRSS);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.push("/podcasts/$rss");
        },
        child: Text(
          artist ?? "Artist",
          style: TextStyle(
            color: color ?? context.theme.onSurface,
            fontSize: size,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
