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
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/ui/utils/gaps.dart';
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
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert_rounded),
                    ),
                  ],
                ),
                sliverGapH8,
                PoddrAppBarOptions(
                  title: const Text("Test"),
                  actions: [
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.abc_outlined))
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
              Center(
                child: Text(
                  "No new episodes",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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
        title: "Loading podcasts...",
        children: [
          ...List.generate(
            5,
            (index) {
              return const ListTile(
                title: ShimmerBox(),
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

    return ContentBox(
      title: "Trending",
      subtitle: "${charts.country} - ${charts.genre}",
      children: [
        if (isMobile)
          ...charts.charts.map((e) {
            return PoddrListItem(
              leading: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: PoddrImage(imageUrl: e.image ?? ''),
              ),
              title: e.title,
              subtitle: e.rss,
              onTap: () {
                context.push('/podcasts/details?rss=${e.rss}');
              },
              actions: [
                PoddrAddSubscriptionBtn(
                  title: e.title ?? '',
                  rss: e.rss ?? '',
                  description: e.description ?? '',
                  author: e.author ?? '',
                  image: e.image ?? '',
                ),
              ],
            );
          })
        else
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              crossAxisSpacing: 32,
              mainAxisSpacing: 32,
              childAspectRatio: 0.8,
            ),
            shrinkWrap: true,
            itemCount: charts.charts.length,
            itemBuilder: (context, index) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    context.push(
                        '/podcasts/details?rss=${charts.charts[index].rss}');
                  },
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: PoddrImage(
                              imageUrl: charts.charts[index].image ?? ''),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  charts.charts[index].title ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              PoddrAddSubscriptionBtn(
                                title: charts.charts[index].title ?? '',
                                rss: charts.charts[index].rss ?? '',
                                description:
                                    charts.charts[index].description ?? '',
                                author: charts.charts[index].author ?? '',
                                image: charts.charts[index].image ?? '',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
