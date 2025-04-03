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
import 'package:poddr/ui/components/widgets/dialog.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/grid_item.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/components/widgets/sliver_box.dart';
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
                ),
                PoddrAppBarOptions(
                  actions: [
                    IconButton(
                      icon: Text(
                          context.watch<PodcastDiscoveryProvider>().country),
                      onPressed: () {
                        final discoveryProvider =
                            context.read<PodcastDiscoveryProvider>();

                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return PoddrDialog(
                              children:
                                  discoveryProvider.countries.map((country) {
                                return SimpleDialogOption(
                                  onPressed: () {
                                    discoveryProvider
                                        .setCountry(country['code'] ?? '');
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: Text(country['name'] ?? ''),
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon:
                          Text(context.watch<PodcastDiscoveryProvider>().genre),
                      onPressed: () {
                        final discoveryProvider =
                            context.read<PodcastDiscoveryProvider>();

                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return PoddrDialog(
                              children: discoveryProvider.genres.map((genre) {
                                return SimpleDialogOption(
                                  onPressed: () {
                                    discoveryProvider
                                        .setGenre(genre['id'] ?? '');
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: Text(genre['genre'] ?? ''),
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    5,
                    (index) => Container(
                      width: 200,
                      height: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const ShimmerBox(),
                    ),
                  ),
                ),
              )
            else if (latestEpisodesProvider.episodes.isEmpty)
              Text(
                "No episodes available",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      latestEpisodesProvider.episodes.take(10).map((episode) {
                    return PoddrGridItem(
                      width: 200,
                      height: 140,
                      leading: Container(
                        clipBehavior: Clip.antiAlias,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: PoddrImage(imageUrl: episode.imageUrl ?? ""),
                      ),
                      title: episode.title,
                      titleMaxLines: 1,
                      subtitle: episode.author,
                      subtitleMaxLines: 1,
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
                    );
                  }).toList(),
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
        historyProvider.isLoading
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    5,
                    (index) => Container(
                      width: 200,
                      height: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const ShimmerBox(),
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: historyProvider.history.map((history) {
                    return PoddrGridItem(
                      width: 200,
                      height: 140,
                      leading: Container(
                        clipBehavior: Clip.antiAlias,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: PoddrImage(imageUrl: history.imageUrl ?? ""),
                      ),
                      title: history.title,
                      titleMaxLines: 1,
                      subtitle: history.podcastTitle,
                      subtitleMaxLines: 1,
                      data: EpisodeHistory(audioUrl: history.audioUrl),
                      onTap: () {
                        context.read<MediaProvider>().loadMedia(
                              audioUrl: history.audioUrl,
                              episodeTitle: history.title,
                              podcastTitle: history.podcastTitle,
                              podcastRSS: history.podcastRSS,
                              artUri: history.imageUrl,
                              artist: history.podcastTitle,
                              album: history.podcastTitle,
                              description: history.description,
                            );
                      },
                    );
                  }).toList(),
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

    if (charts.charts.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

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
                    final rss =
                        Uri.encodeComponent(charts.charts[index].rss ?? '');
                    context.push('/podcasts/$rss');
                  },
                  actions: [
                    PoddrAddSubscriptionBtn(rss: charts.charts[index].rss),
                  ],
                );
              },
            )
          : SliverLayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                final width = MediaQuery.sizeOf(context).width;

                if (Breakpoints.isMobile(width)) {
                  crossAxisCount = 2;
                } else if (Breakpoints.isTablet(width)) {
                  crossAxisCount = 3;
                } else if (Breakpoints.isMedium(width)) {
                  crossAxisCount = 4;
                } else if (Breakpoints.isLarge(width)) {
                  crossAxisCount = 5;
                } else {
                  crossAxisCount = 6;
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
                        final rss =
                            Uri.encodeComponent(charts.charts[index].rss ?? '');
                        context.push('/podcasts/$rss');
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
