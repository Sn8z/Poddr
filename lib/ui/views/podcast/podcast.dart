import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/ui/components/widgets/add_subscription_btn.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/dialog.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/components/widgets/sliver_box.dart';
import 'package:poddr/ui/components/widgets/tag.dart';
import 'package:poddr/services/media.dart';
import 'package:poddr/services/podcast.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/utils/string_converter.dart';
import 'package:provider/provider.dart';

class PodcastDetailsView extends StatelessWidget {
  const PodcastDetailsView({super.key, required this.rss});
  final String rss;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PodcastProvider(),
      builder: (context, child) {
        final podcastProvider = context.watch<PodcastProvider>();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          podcastProvider.getPodcast(rss);
        });

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: Text(
                    podcastProvider.podcast?.author ?? "Author",
                    maxLines: 1,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.surfaceContainerLow
                          : Theme.of(context).colorScheme.primaryContainer,
                  flexibleSpace: FlexibleSpaceBar(
                    background: LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile =
                            constraints.maxWidth < Breakpoints.mobileScreen;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Theme.of(context)
                                          .colorScheme
                                          .surfaceContainer,
                                      Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerLow,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: isMobile
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 120,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: PoddrImage(
                                            imageUrl: podcastProvider
                                                    .podcast?.image ??
                                                "",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        gapH8,
                                        Text(
                                          podcastProvider.podcast?.title ?? "",
                                          style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        gapH8,
                                        Text(
                                          podcastProvider
                                                  .podcast?.description ??
                                              "",
                                          maxLines: 3,
                                          style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          height: 200,
                                          width: 200,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: PoddrImage(
                                            imageUrl: podcastProvider
                                                    .podcast?.image ??
                                                "",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        gapW16,
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                podcastProvider
                                                        .podcast?.title ??
                                                    "",
                                                style: TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                              ),
                                              Text(
                                                podcastProvider
                                                        .podcast?.description ??
                                                    "",
                                                maxLines: 3,
                                                style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                              gapH16,
                                              Text(
                                                "${podcastProvider.podcast?.episodes.length ?? 0} Episodes",
                                                style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                              ),
                                              gapH16,
                                              Row(
                                                children: podcastProvider
                                                        .podcast?.tags
                                                        .map((e) => PoddrTag(
                                                              title: e,
                                                              color:
                                                                  Colors.grey,
                                                            ))
                                                        .toList() ??
                                                    [],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  expandedHeight: 280,
                  actions: const [],
                ),
                PoddrAppBarOptions(
                  title: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.sort_rounded),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search_rounded),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return PoddrDialog(
                                children: [
                                  PoddrTextInput(
                                    labelText: "Filter",
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  actions: [
                    PoddrAddSubscriptionBtn(rss: rss),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert_rounded),
                    ),
                  ],
                ),
                sliverGapH8,
                if (podcastProvider.isLoading)
                  SliverList.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return const ListTile(
                        title: ShimmerBox(
                          height: 48,
                          radius: 16,
                        ),
                      );
                    },
                  )
                else if (podcastProvider.podcast == null)
                  const SliverFillRemaining(
                    child: Text("No podcast found"),
                  )
                else
                  PoddrSliverBox(
                    sliver: SliverList.builder(
                      itemCount: podcastProvider.podcast!.episodes.length,
                      itemBuilder: (context, index) {
                        return Episode(
                            episode: podcastProvider.podcast!.episodes[index]);
                      },
                    ),
                  ),
                const BottomPaddingFix(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Episode extends StatelessWidget {
  final PodcastEpisode episode;

  const Episode({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    final podcastProvider = context.read<PodcastProvider>();

    final isCurrentEpisode =
        context.select<MediaProvider, bool>((mediaProvider) {
      return mediaProvider.mediaItem.value?.title == episode.title;
    });

    return PoddrListItem(
      title: episode.title,
      subtitle: convertDateToString(episode.publicationDate),
      data: EpisodeHistory(
        audioUrl: episode.audioUrl,
        width: 460,
      ),
      isActive: isCurrentEpisode,
      actions: [
        Text(
          convertDurationToString(
            episode.duration,
          ),
          maxLines: 1,
          style: TextStyle(
            color: isCurrentEpisode
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.info_outline_rounded),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return PoddrDialog(
                  children: [
                    Text(episode.description),
                  ],
                );
              },
            );
          },
        ),
        IconButton(
          onPressed: () {
            context.read<MediaProvider>().addToQueue(
                  audioUrl: episode.audioUrl,
                  episodeTitle: episode.title,
                  podcastTitle: episode.title,
                  podcastRSS: podcastProvider.podcast!.rss ?? "Missing RSS",
                  description: episode.description,
                  artUri: podcastProvider.podcast!.image,
                  album: episode.title,
                  artist: podcastProvider.podcast!.author,
                );
          },
          icon: const Icon(Icons.queue_music_rounded),
        ),
      ],
      onTap: () {
        context.read<MediaProvider>().loadMedia(
              audioUrl: episode.audioUrl,
              episodeTitle: episode.title,
              podcastTitle: episode.title,
              podcastRSS: podcastProvider.podcast!.rss ?? "Missing RSS",
              description: episode.description,
              artUri: podcastProvider.podcast!.image,
              album: episode.title,
              artist: podcastProvider.podcast!.author,
            );
      },
    );
  }
}
