import 'package:flutter/material.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/services/offline.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/components/widgets/download_button.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/utils/string_converter.dart';
import 'package:provider/provider.dart';

class DownloadsView extends StatelessWidget {
  const DownloadsView({super.key});

  @override
  Widget build(BuildContext context) {
    final offlineProvider = context.watch<OfflineProvider>();
    final downloads = offlineProvider.downloads;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [
            PoddrAppBar(
              title: 'Downloads',
              actions: [
                if (downloads.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _showClearAllDialog(context, offlineProvider);
                    },
                    icon: const Icon(Icons.delete_sweep_rounded),
                    tooltip: 'Clear all downloads',
                  ),
              ],
            ),
            PoddrAppBarOptions(),
            sliverGapH16,
            if (offlineProvider.isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (downloads.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.download_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      gapH16,
                      Text(
                        'No downloads yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      gapH8,
                      Text(
                        'Download episodes to listen offline',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
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
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: PoddrImage(imageUrl: download.imageUrl),
                      ),
                      onTap: () {
                        context.read<MediaProvider>().loadMedia(
                              audioUrl: download.audioUrl,
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
                        EpisodeHistoryCircle(audioUrl: download.audioUrl),
                        DownloadButton(
                          episode: offlineProvider.toPodcastEpisode(download)!,
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
  }

  void _showClearAllDialog(BuildContext context, OfflineProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear all downloads?'),
          content: Text(
            'This will delete ${provider.downloads.length} downloaded episode(s).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                for (var download in provider.downloads) {
                  provider.remove(download.audioUrl);
                }
                Navigator.pop(context);
              },
              child: Text(
                'Delete all',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
