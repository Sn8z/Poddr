import 'package:flutter/material.dart';
import 'package:poddr/services/media.dart';
import 'package:provider/provider.dart';

class CurrentlyPlayingIcon extends StatelessWidget {
  const CurrentlyPlayingIcon({super.key, required this.episodeSource});
  final String episodeSource;

  @override
  Widget build(BuildContext context) {
    String? currentEpisode =
        context.select<MediaProvider, String?>((e) => e.mediaItem.value?.title);

    final isCurrentEpisode = currentEpisode == episodeSource;

    if (isCurrentEpisode) {
      return Icon(
        Icons.audiotrack_rounded,
        color: Theme.of(context).colorScheme.primary,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
