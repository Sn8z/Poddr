import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/services/history.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/add_subscription_btn.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/layouts/page_layout.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/views/discover/discover_view_model.dart';

import 'package:poddr/ui/components/widgets/box.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/grid_item.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
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
          slivers: [
            PoddrAppBar(
              title: const Text('Podcasts'),
              bottom: PoddrAppBarOptions(
                actions: [
                  PoddrOutlinedButton(
                    child: Text(context.watch<DiscoverViewModel>().country),
                    onPressed: () {
                      final discoveryProvider =
                          context.read<DiscoverViewModel>();

                      showPoddrDialog(
                        context: context,
                        builder: (dialogContext) {
                          return _CountrySelectionDialog(
                            discoveryProvider: discoveryProvider,
                            dialogContext: dialogContext,
                          );
                        },
                      );
                    },
                  ),
                  gapW8,
                  PoddrOutlinedButton(
                    child: Text(context.watch<DiscoverViewModel>().genre),
                    onPressed: () {
                      final discoveryProvider =
                          context.read<DiscoverViewModel>();

                      showPoddrDialog(
                        context: context,
                        builder: (dialogContext) {
                          return _GenreSelectionDialog(
                            discoveryProvider: discoveryProvider,
                            dialogContext: dialogContext,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            sliverGapH16,
            const LatestEpisodes(),
            sliverGapH16,
            const RecentlyPlayedEpisodesSliver(),
            sliverGapH16,
            const TrendingPodcastsSliver(),
          ],
        );
      },
    );
  }
}

class _CountrySelectionDialog extends StatefulWidget {
  final DiscoverViewModel discoveryProvider;
  final BuildContext dialogContext;

  const _CountrySelectionDialog({
    required this.discoveryProvider,
    required this.dialogContext,
  });

  @override
  State<_CountrySelectionDialog> createState() =>
      _CountrySelectionDialogState();
}

class _CountrySelectionDialogState extends State<_CountrySelectionDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredCountries = widget.discoveryProvider.countries
        .where((country) =>
            country.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return PoddrDialog(
      header: Text(
        "Select country",
        style: context.theme.textTheme.headlineSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: context.theme.secondary,
        ),
      ),
      showCloseButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PoddrTextInput(
            hintText: "Search countries...",
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          gapH12,
          ...filteredCountries.map((country) {
            final isActive =
                widget.discoveryProvider.countryCode == country.code;
            return PoddrListItem(
              title: country.name,
              isActive: isActive,
              onTap: () {
                widget.discoveryProvider.setCountry(country.code);
                Navigator.of(widget.dialogContext).pop();
              },
            );
          }),
        ],
      ),
    );
  }
}

class _GenreSelectionDialog extends StatelessWidget {
  final DiscoverViewModel discoveryProvider;
  final BuildContext dialogContext;

  const _GenreSelectionDialog({
    required this.discoveryProvider,
    required this.dialogContext,
  });

  @override
  Widget build(BuildContext context) {
    return PoddrDialog(
      header: Text(
        "Select genre",
        style: context.theme.textTheme.headlineSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: context.theme.secondary,
        ),
      ),
      showCloseButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: discoveryProvider.genres.map((genre) {
          final isActive = discoveryProvider.genreID == genre.id;
          return PoddrListItem(
            title: genre.name,
            isActive: isActive,
            onTap: () {
              discoveryProvider.setGenre(genre.id);
              Navigator.of(dialogContext).pop();
            },
          );
        }).toList(),
      ),
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
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowRight01,
          ),
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
            style: context.theme.textTheme.bodyLarge.copyWith(
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
                    child: PoddrImage(
                        imageUrl: episode.imageUrl ?? "",
                        maxHeightDiskCache: 300),
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

class RecentlyPlayedEpisodesSliver extends StatelessWidget {
  const RecentlyPlayedEpisodesSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();

    if (historyProvider.history.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
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
                        child: PoddrImage(
                            imageUrl: history.imageUrl ?? "",
                            maxHeightDiskCache: 300),
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

class TrendingPodcastsSliver extends StatelessWidget {
  const TrendingPodcastsSliver({super.key});

  static int _calcCrossAxisCount(double width) {
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    final charts = context.watch<DiscoverViewModel>();

    final isMobile =
        MediaQuery.of(context).size.width < Breakpoints.mobileScreen;

    if (charts.charts.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
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

    return isMobile
        ? SliverMainAxisGroup(
            slivers: [
              DecoratedSliver(
                decoration: BoxDecoration(
                  color: context.theme.surfaceContainerLow,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                sliver: const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return PoddrListItem(
                      leading: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: PoddrImage(
                            imageUrl: charts.charts[index].image ?? '',
                            maxHeightDiskCache: 300),
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
                  childCount: charts.charts.length,
                ),
              ),
              DecoratedSliver(
                decoration: BoxDecoration(
                  color: context.theme.surfaceContainerLow,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                sliver: const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ),
            ],
          )
        : SliverLayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount =
                  _calcCrossAxisCount(constraints.crossAxisExtent);
              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
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
                          maxHeightDiskCache: 300,
                        ),
                      ),
                      title: charts.charts[index].title,
                      subtitle: charts.charts[index].link,
                      actions: [
                        PoddrAddSubscriptionBtn(rss: charts.charts[index].rss),
                      ],
                    );
                  },
                  childCount: charts.charts.length,
                ),
              );
            },
          );
  }
}
