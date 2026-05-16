import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:provider/provider.dart';

class CurrentlyPlayingIcon extends StatelessWidget {
  const CurrentlyPlayingIcon({super.key, required this.episodeSource});
  final String episodeSource;

  @override
  Widget build(BuildContext context) {
    String? currentEpisode =
        context.select<MediaProvider, String?>((e) => e.podcastTitle);

    final isCurrentEpisode = currentEpisode == episodeSource;

    if (isCurrentEpisode) {
      return Icon(
        LucideIcons.music,
        color: context.theme.primary,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
