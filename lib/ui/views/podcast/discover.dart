import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/services/history.dart';
import 'package:poddr/services/latest_episodes.dart';
import 'package:poddr/services/media.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/add_subscription_btn.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/services/podcast_discovery.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/grid_item.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/components/widgets/sliver_box.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/utils/platform.dart';
import 'package:provider/provider.dart';

class PodcastDiscoveryView extends StatelessWidget {
  const PodcastDiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PodcastDiscoveryProvider(),
      builder: (context, child) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomScrollView(
              slivers: [
                PoddrAppBar(
                  title: "Podcasts",
                ),
                PoddrAppBarOptions(
                  title: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.view_module_rounded),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.view_headline_rounded),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert_rounded),
                    ),
                  ],
                ),
                sliverGapH8,
                const LatestEpisodes(),
                sliverGapH8,
                const RecentlyPlayedEpisodes(),
                sliverGapH8,
                const TrendingPodcasts(),
                const BottomPaddingFix(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LatestEpisodes extends StatelessWidget {
  const LatestEpisodes({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LatestEpisodesProvider>(
      create: (context) =>
          LatestEpisodesProvider(context.read<SubscriptionProvider>()),
      builder: (context, child) {
        final latestEpisodesProvider = context.watch<LatestEpisodesProvider>();
        return ContentBox(
          title: "Latest episodes",
          children: [
            if (latestEpisodesProvider.isLoading)
              Row(
                children: List.generate(
                  5,
                  (index) => Container(
                    width: 140,
                    height: 140,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const ShimmerBox(),
                  ),
                ),
              )
            else if (latestEpisodesProvider.episodes.isEmpty)
              Text(
                "No new episodes",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: latestEpisodesProvider.episodes
                      .take(10)
                      .map(
                        (episode) => MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              context.read<MediaProvider>().loadMedia(
                                    audioUrl: episode.audioUrl,
                                    episodeTitle: episode.title,
                                    podcastTitle: episode.podcastTitle,
                                    podcastRSS: episode.podcastRSS,
                                    artUri: episode.imageUrl,
                                    artist: episode.podcastTitle,
                                    album: episode.podcastTitle,
                                    description: episode.description,
                                  );
                            },
                            child: Container(
                              width: 140,
                              height: 120,
                              margin: const EdgeInsets.only(right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 140,
                                    height: 80,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: PoddrImage(
                                            imageUrl: episode.imageUrl ?? '',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    episode.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    episode.title,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class RecentlyPlayedEpisodes extends StatelessWidget {
  const RecentlyPlayedEpisodes({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();

    if (historyProvider.history.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return ContentBox(
      title: "Continue listening",
      children: [
        if (historyProvider.isLoading)
          Row(
            children: List.generate(
              5,
              (index) => Container(
                width: 140,
                height: 140,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const ShimmerBox(),
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: historyProvider.history
                  .map(
                    (h) => MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          context.read<MediaProvider>().loadMedia(
                                audioUrl: h.audioUrl,
                                episodeTitle: h.title,
                                podcastTitle: h.podcastTitle,
                                podcastRSS: h.podcastRSS,
                                artUri: h.imageUrl,
                                artist: h.podcastTitle,
                                album: h.podcastTitle,
                                description: h.description,
                              );
                        },
                        child: Container(
                          width: 140,
                          height: 120,
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 140,
                                height: 80,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: PoddrImage(
                                        imageUrl: h.imageUrl ?? '',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child:
                                          EpisodeHistory(audioUrl: h.audioUrl),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                h.title,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class TrendingPodcasts extends StatelessWidget {
  const TrendingPodcasts({super.key});

  @override
  Widget build(BuildContext context) {
    final charts = context.watch<PodcastDiscoveryProvider>();

    final isMobile =
        MediaQuery.of(context).size.width < Breakpoints.mobileScreen;

    if (charts.isLoading) {
      return ContentBox(
        children: [
          ...List.generate(
            5,
            (index) {
              return const ListTile(
                title: ShimmerBox(
                  height: 28,
                ),
              );
            },
          ),
        ],
      );
    }

    if (charts.charts.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return PoddrSliverBox(
      sliver: isMobile
          ? SliverList.builder(
              itemCount: charts.charts.length,
              itemBuilder: (context, index) {
                return PoddrListItem(
                  leading: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child:
                        PoddrImage(imageUrl: charts.charts[index].image ?? ''),
                  ),
                  title: charts.charts[index].title,
                  subtitle: charts.charts[index].rss,
                  onTap: () {
                    context.push(
                        '/podcasts/details?rss=${charts.charts[index].rss}');
                  },
                  actions: [
                    PoddrAddSubscriptionBtn(rss: charts.charts[index].rss),
                  ],
                );
              },
            )
          : SliverLayoutBuilder(
              builder: (context, constraints) {
                var crossAxisCount = 5;
                final width = MediaQuery.of(context).size.width;

                if (width >= Breakpoints.desktopScreen) {
                  crossAxisCount = 6;
                } else if (width >= Breakpoints.tabletScreen) {
                  crossAxisCount = 4;
                } else if (width >= Breakpoints.mobileScreen) {
                  crossAxisCount = 3;
                } else {
                  crossAxisCount = 2;
                }

                return SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: charts.charts.length,
                  itemBuilder: (context, index) {
                    return PoddrGridItem(
                      onTap: () {
                        context.push(
                            '/podcasts/details?rss=${charts.charts[index].rss}');
                      },
                      leading: Container(
                        clipBehavior: Clip.antiAlias,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: PoddrImage(
                          imageUrl: charts.charts[index].image ?? '',
                        ),
                      ),
                      title: charts.charts[index].title,
                      subtitle: charts.charts[index].link,
                      actions: [
                        PoddrAddSubscriptionBtn(rss: charts.charts[index].rss),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}
