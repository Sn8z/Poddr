import 'package:flutter/material.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

class EpisodeTitle extends StatelessWidget {
  final double size;
  final Color? color;

  const EpisodeTitle({
    super.key,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    String? title =
        context.select<MediaProvider, String?>((e) => e.episodeTitle);
    String? rss = context.select<MediaProvider, String?>((e) => e.podcastRSS);

    final encodedRSS = rss != null && rss.isNotEmpty 
        ? Uri.encodeComponent(rss) 
        : null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: encodedRSS != null
            ? () => context.push("/podcasts/$encodedRSS")
            : null,
        child: Text(
          title ?? "Title",
          style: TextStyle(
            color: color ?? context.theme.primary,
            fontWeight: FontWeight.bold,
            fontSize: size,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
