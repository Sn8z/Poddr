import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/services/history.dart';
import 'package:poddr/ui/components/widgets/add_subscription_btn.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/services/podcast_discovery.dart';
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

    if (historyProvider.isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DiscoveryBox(
      title: "Continue listening",
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: historyProvider.history
                .map((h) => Container(
                      width: 140,
                      height: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          h.title,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ))
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

    if (isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DiscoveryBox(
      title: "Trending",
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items
                .sublist(0, 5)
                .map(
                  (e) => MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        context.push('/podcasts/details?rss=${e.rss}');
                      },
                      child: Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 12),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image(
                                image: NetworkImage(e.image ?? ''),
                              ),
                            ),
                            Text(
                              e.title ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                              ),
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
        gapH8,
        ...items.sublist(5, items.length).map(
          (e) {
            return ListTile(
              title: Text(e.title ?? ''),
              subtitle: Text(
                e.rss ?? '',
              ),
              onTap: () {
                context.push('/podcasts/details?rss=${e.rss}');
              },
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
