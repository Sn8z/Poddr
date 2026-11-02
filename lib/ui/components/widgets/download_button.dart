import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/services/offline.dart';
import 'package:poddr/ui/components/widgets/poddr_error_dialog.dart';
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
    final view = context.select<OfflineProvider, DownloadView>(
      (p) => p.downloadView(episode.audioUrl),
    );

    switch (view.state) {
      case DownloadState.downloading:
        return SizedBox(
          width: iconSize,
          height: iconSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PoddrLinearProgress(
                value: view.progress,
                height: 2,
              ),
              PoddrIconButton(
                onPressed: () {
                  context.read<OfflineProvider>().cancelDownload(
                        episode.audioUrl,
                      );
                },
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                ),
                size: 14,
              ),
            ],
          ),
        );
      case DownloadState.queued:
        return Stack(
          alignment: Alignment.center,
          children: [
            PoddrIconButton(
              onPressed: () {
                context.read<OfflineProvider>().cancelDownload(
                      episode.audioUrl,
                    );
              },
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedLoading01,
              ),
              size: 14,
            ),
            if (view.queuePosition > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: context.theme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 10, minHeight: 10),
                  child: Text(
                    '${view.queuePosition}',
                    style: context.theme.textTheme.labelSmall.copyWith(
                      color: context.theme.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      case DownloadState.failed:
        return PoddrIconButton(
          onPressed: () {
            context.read<OfflineProvider>().download(episode);
          },
          onLongPress: view.error == null
              ? null
              : () => showPoddrErrorDialog(
                    context: context,
                    message: view.error!,
                    title: 'Download failed',
                  ),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedRefresh,
            color: context.theme.error,
          ),
          size: iconSize,
          semanticLabel: view.error ?? 'Download failed, tap to retry',
        );
      case DownloadState.downloaded:
        return PoddrIconButton(
          onPressed: () async {
            final offlineProvider = context.read<OfflineProvider>();
            final removed = await offlineProvider.remove(episode.audioUrl);
            if (!removed && context.mounted) {
              await showPoddrErrorDialog(
                context: context,
                message: offlineProvider.lastError ??
                    'The downloaded episode could not be removed. '
                        'Please try again.',
              );
            }
          },
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedCancel01,
          ),
          size: iconSize,
          semanticLabel: 'Delete download',
        );
      case DownloadState.idle:
        return PoddrIconButton(
          onPressed: () {
            context.read<OfflineProvider>().download(episode);
          },
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedDownload01,
          ),
          size: iconSize,
        );
    }
  }
}
