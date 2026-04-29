import 'package:flutter/material.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/services/offline.dart';
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
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
            ),
            IconButton(
              onPressed: () {
                offlineProvider.cancelDownload(episode.audioUrl);
              },
              icon: const Icon(Icons.close, size: 14),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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
          IconButton(
            onPressed: () {
              offlineProvider.cancelDownload(episode.audioUrl);
            },
            icon: const Icon(Icons.schedule, size: 14),
            tooltip: 'Queued (position $queuePosition) - tap to cancel',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          if (queuePosition > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                child: Text(
                  '$queuePosition',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    }

    if (isDownloaded) {
      return IconButton(
        onPressed: () {
          offlineProvider.remove(episode.audioUrl);
        },
        icon: Icon(
          Icons.delete_outline_rounded,
          size: iconSize,
        ),
        tooltip: 'Remove download',
      );
    }

    return IconButton(
      onPressed: () {
        offlineProvider.download(episode);
      },
      icon: Icon(
        Icons.download_outlined,
        size: iconSize,
      ),
      tooltip: 'Download for offline',
    );
  }
}
