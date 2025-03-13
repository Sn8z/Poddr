import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/services/history.dart';
import 'package:poddr/services/media.dart';
import 'package:poddr/ui/components/widgets/add_subscription_btn.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/services/podcast_discovery.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/image.dart';
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
                sliverGapH16,
                const NewEpisodes(),
                sliverGapH16,
                const RecentlyPlayedEpisodes(),
                sliverGapH16,
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

class NewEpisodes extends StatelessWidget {
  const NewEpisodes({super.key});

  @override
  Widget build(BuildContext context) {
    return DiscoveryBox(
      title: "New episodes",
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              10,
              (index) => Container(
                width: 140,
                height: 140,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Item $index",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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

    return DiscoveryBox(
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
                  color: Theme.of(context).colorScheme.primaryContainer,
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: PoddrImage(
                                  imageUrl: h.imageUrl ?? '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              EpisodeHistory(audioUrl: h.audioUrl),
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
    final isLoading = charts.isLoading;
    final items = charts.charts;

    final isMobile =
        MediaQuery.of(context).size.width < Breakpoints.mobileScreen;

    if (isLoading) {
      return DiscoveryBox(
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

    if (items.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return DiscoveryBox(
      title: "Trending",
      children: [
        if (isMobile)
          ...items.map((e) {
            return ListTile(
              leading: PoddrImage(imageUrl: e.image ?? ''),
              title: Text(e.title ?? ''),
              subtitle: Text(
                e.rss ?? '',
              ),
              onTap: () {
                context.push('/podcasts/details?rss=${e.rss}');
              },
              trailing: PoddrAddSubscriptionBtn(
                title: e.title ?? '',
                rss: e.rss ?? '',
                description: e.description ?? '',
                author: e.author ?? '',
                image: e.image ?? '',
              ),
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
            itemCount: items.length,
            itemBuilder: (context, index) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    context.push('/podcasts/details?rss=${items[index].rss}');
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
                          child: PoddrImage(imageUrl: items[index].image ?? ''),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  items[index].title ?? '',
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
                                title: items[index].title ?? '',
                                rss: items[index].rss ?? '',
                                description: items[index].description ?? '',
                                author: items[index].author ?? '',
                                image: items[index].image ?? '',
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

class DiscoveryBox extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const DiscoveryBox({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            gapH8,
            ...children,
          ],
        ),
      ),
    );
  }
}
