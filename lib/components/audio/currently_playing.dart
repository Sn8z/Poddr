import 'package:flutter/material.dart';
import 'package:poddr/providers/media.dart';
import 'package:provider/provider.dart';

class CurrentlyPlayingIcon extends StatelessWidget {
  const CurrentlyPlayingIcon({super.key, required this.episodeSource});
  final String episodeSource;

  @override
  Widget build(BuildContext context) {
    String? currentEpisode =
        context.select<MediaProvider, String?>((e) => e.mediaItem.value?.title);

    final isCurrentEpisode = currentEpisode == episodeSource;

    return Icon(
      isCurrentEpisode ? Icons.audiotrack_rounded : null,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
