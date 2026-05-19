import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/services/offline.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/poddr_progress.dart';
import 'package:provider/provider.dart';

class DownloadButton extends StatelessWidget {
  final PodcastEpisode episode;
  final double iconSize;

  const DownloadButton({
    super.key,
    required this.episode,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final offlineProvider = context.watch<OfflineProvider>();
    final isDownloading = offlineProvider.downloading.contains(episode.audioUrl);
    final progress = offlineProvider.downloadProgress[episode.audioUrl];
    final isDownloaded = offlineProvider.downloads.any(
      (d) => d.audioUrl == episode.audioUrl,
    );
    final isQueued = offlineProvider.downloadQueue.any(
      (e) => e.audioUrl == episode.audioUrl,
    );

    if (isDownloading) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PoddrLinearProgress(
              value: progress ?? 0,
              height: 2,
            ),
            PoddrIconButton(
              onPressed: () {
                offlineProvider.cancelDownload(episode.audioUrl);
              },
              icon: const Icon(LucideIcons.x),
              size: 14,
            ),
          ],
        ),
      );
    }

    if (isQueued) {
      final queuePosition = offlineProvider.getQueuePosition(episode.audioUrl);
      return Stack(
        alignment: Alignment.center,
        children: [
          PoddrIconButton(
            onPressed: () {
              offlineProvider.cancelDownload(episode.audioUrl);
            },
            icon: const Icon(LucideIcons.clock),
            size: 14,
          ),
          if (queuePosition > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: context.theme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                child: Text(
                  '$queuePosition',
                  style: context.theme.textTheme.labelSmall.copyWith(
                    color: context.theme.onPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    }

    if (isDownloaded) {
      return PoddrIconButton(
        onPressed: () {
          offlineProvider.remove(episode.audioUrl);
        },
        icon: const Icon(LucideIcons.trash),
        size: iconSize,
      );
    }

    return PoddrIconButton(
      onPressed: () {
        offlineProvider.download(episode);
      },
      icon: const Icon(LucideIcons.download),
      size: iconSize,
    );
  }
}
