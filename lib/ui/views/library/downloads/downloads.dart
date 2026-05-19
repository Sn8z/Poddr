import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/services/offline.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/components/widgets/download_button.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_confirm_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/empty_state.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/layouts/page_layout.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/utils/string_converter.dart';
import 'package:poddr/ui/views/library/downloads/downloads_view_model.dart';
import 'package:provider/provider.dart';

class DownloadsView extends StatelessWidget {
  const DownloadsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider2<OfflineProvider, MediaProvider,
        DownloadsViewModel>(
      create: (context) => DownloadsViewModel(
        context.read<OfflineProvider>(),
        context.read<MediaProvider>(),
      ),
      update: (_, offline, media, previous) =>
          previous ?? DownloadsViewModel(offline, media),
      builder: (context, child) {
        final viewModel = context.watch<DownloadsViewModel>();
        final downloads = viewModel.downloads;

        return PageLayout(
          header: PoddrAppBar(
            title: 'Downloads',
            actions: [
              if (downloads.isNotEmpty)
                PoddrIconButton(
                  onPressed: () {
                    _showClearAllDialog(context, viewModel);
                  },
                  icon: const Icon(LucideIcons.trash),
                ),
            ],
          ),
          child: viewModel.isLoading
              ? const ShimmerLoadingList()
              : downloads.isEmpty
                  ? const EmptyState(
                      icon: LucideIcons.download,
                      title: 'No downloads yet',
                      subtitle: 'Download episodes to listen offline',
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          gapH16,
                          ContentBox(
                            title: "Episodes (${downloads.length})",
                            children: [
                              for (var download in downloads)
                                PoddrListItem(
                                  title: download.title,
                                  subtitle: download.podcastTitle,
                                  leading: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                    ),
                                    child:
                                        PoddrImage(imageUrl: download.imageUrl),
                                  ),
                                  onTap: () {
                                    viewModel.loadMedia(
                                      audioUrl: download.audioUrl,
                                      videoUrl: download.videoUrl,
                                      episodeTitle: download.title,
                                      podcastTitle: download.podcastTitle,
                                      podcastRSS: download.podcastRSS,
                                      description: download.description,
                                      artUri: download.imageUrl,
                                      album: download.title,
                                      artist: download.podcastTitle,
                                    );
                                  },
                                  actions: [
                                    Text(
                                      convertDurationToString(
                                        Duration(seconds: download.duration),
                                      ),
                                    ),
                                    EpisodeHistoryCircle(
                                        audioUrl: download.audioUrl),
                                    DownloadButton(
                                      episode:
                                          viewModel.toPodcastEpisode(download)!,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const BottomPaddingFix(),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  void _showClearAllDialog(BuildContext context, DownloadsViewModel viewModel) {
    showPoddrDialog(
      context: context,
      builder: (dialogContext) {
        return PoddrConfirmDialog(
          title: 'Clear all downloads?',
          message:
              'This will delete ${viewModel.downloads.length} downloaded episode(s).',
          confirmLabel: 'Delete all',
          onConfirm: () {
            viewModel.clearAllDownloads();
            Navigator.pop(dialogContext);
          },
        );
      },
    );
  }
}
