import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/services/history.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/add_subscription_btn.dart';
import 'package:poddr/ui/layouts/page_layout.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/views/discover/discover_view_model.dart';

import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/components/widgets/box.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/grid_item.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:provider/provider.dart';

class PodcastDiscoveryView extends StatelessWidget {
  const PodcastDiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiscoverViewModel(),
      builder: (context, child) {
        return PageLayout(
          header: const PoddrAppBar(title: "Podcasts"),
          options: PoddrAppBarOptions(
            actions: [
              PoddrIconButton(
                icon: Text(context.watch<DiscoverViewModel>().country),
                onPressed: () {
                  final discoveryProvider = context.read<DiscoverViewModel>();

                  showPoddrDialog(
                    context: context,
                    builder: (dialogContext) {
                      return PoddrDialog(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: discoveryProvider.countries.map((country) {
                            return GestureDetector(
                              onTap: () {
                                discoveryProvider.setCountry(country.code);
                                Navigator.of(dialogContext).pop();
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(country.name),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
              ),
              PoddrIconButton(
                icon: Text(context.watch<DiscoverViewModel>().genre),
                onPressed: () {
                  final discoveryProvider = context.read<DiscoverViewModel>();

                  showPoddrDialog(
                    context: context,
                    builder: (dialogContext) {
                      return PoddrDialog(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: discoveryProvider.genres.map((genre) {
                            return GestureDetector(
                              onTap: () {
                                discoveryProvider.setGenre(genre.id);
                                Navigator.of(dialogContext).pop();
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(genre.name),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          children: [
            gapH16,
            const LatestEpisodes(),
            gapH16,
            const RecentlyPlayedEpisodes(),
            gapH16,
            const TrendingPodcasts(),
            gapH16,
            const BottomPaddingFix(),
          ],
        );
      },
    );
  }
}

class LatestEpisodes extends StatelessWidget {
  const LatestEpisodes({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    return ContentBox(
      title: "Latest episodes",
      actions: [
        PoddrIconButton(
          icon: const Icon(LucideIcons.chevronRight),
          onPressed: () {
            context.push('/library/latest');
          },
        ),
      ],
      children: [
        if (subscriptionProvider.isLoadingLatest)
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
        else if (subscriptionProvider.latestEpisodes.isEmpty)
          Text(
            "No episodes available",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: context.theme.onSurfaceVariant,
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  subscriptionProvider.latestEpisodes.take(10).map((episode) {
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
                  data: EpisodeHistory(audioUrl: episode.audioUrl),
                  onTap: () {
                    context.read<MediaProvider>().loadMedia(
                          audioUrl: episode.audioUrl,
                          videoUrl: episode.videoUrl,
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
  }
}

class RecentlyPlayedEpisodes extends StatelessWidget {
  const RecentlyPlayedEpisodes({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();

    if (historyProvider.history.isEmpty) {
      return const SizedBox.shrink();
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
                              videoUrl: history.videoUrl,
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
    final charts = context.watch<DiscoverViewModel>();

    final isMobile =
        MediaQuery.of(context).size.width < Breakpoints.mobileScreen;

    if (charts.charts.isEmpty) {
      return const SizedBox.shrink();
    }

    if (charts.isLoading) {
      return ContentBox(
        children: [
          ...List.generate(
            5,
            (index) {
              return const PoddrListItem(
                data: ShimmerBox(
                  height: 28,
                ),
              );
            },
          ),
        ],
      );
    }

    return PoddrBox(
      child: isMobile
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
          : LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                final width = constraints.maxWidth;

                if (width < 600) {
                  crossAxisCount = 2;
                } else if (width < 900) {
                  crossAxisCount = 3;
                } else if (width < 1200) {
                  crossAxisCount = 4;
                } else {
                  crossAxisCount = 5;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
