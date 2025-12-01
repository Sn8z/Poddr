import 'package:flutter/material.dart';
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

    return Text(
      title ?? "Title",
      style: TextStyle(
        color: color ?? Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: size,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
