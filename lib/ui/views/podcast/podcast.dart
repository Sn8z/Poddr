import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/collection.dart';
import 'package:poddr/ui/components/widgets/add_subscription_btn.dart';
import 'package:poddr/ui/components/widgets/collections_display.dart';
import 'package:poddr/ui/components/widgets/collection_link_button.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/box.dart';
import 'package:poddr/ui/components/widgets/download_button.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/html.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/ui/views/podcast/podcast_view_model.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/poddr_list.dart';
import 'package:poddr/ui/components/widgets/podcast_header.dart';
import 'package:poddr/ui/components/widgets/empty_state.dart';
import 'package:poddr/ui/layouts/page_layout.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/utils/sort_fields.dart';
import 'package:poddr/ui/utils/string_converter.dart';
import 'package:provider/provider.dart';

class PodcastDetailsView extends StatelessWidget {
  const PodcastDetailsView({super.key, required this.rss});
  final String rss;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PodcastViewModel(initialRss: rss),
      builder: (context, child) {
        final podcastProvider = context.watch<PodcastViewModel>();

        return PageLayout(
          header: PodcastHeader(
            podcastProvider: podcastProvider,
            bottom: PoddrAppBarOptions(
              title: LayoutBuilder(
                builder: (layoutContext, constraints) {
                  if (constraints.maxWidth > Breakpoints.tabletScreen) {
                    return Row(
                      children: [
                        PoddrIconButton(
                          icon: const Icon(LucideIcons.filter),
                          onPressed: () {
                            _showFilterSortDialog(context, podcastProvider);
                          },
                        ),
                        gapW8,
                        Expanded(
                          child: PoddrTextInput(
                            controller: podcastProvider.filterController,
                            hintText: "Type to filter episodes...",
                            onChanged: (value) {
                              podcastProvider.setFilter(value);
                            },
                            suffixIcon: podcastProvider.filter.isNotEmpty
                                ? PoddrIconButton(
                                    icon: const Icon(LucideIcons.x),
                                    size: 20,
                                    onPressed: () {
                                      podcastProvider.setFilter('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        PoddrIconButton(
                          icon: const Icon(LucideIcons.filter),
                          onPressed: () {
                            _showFilterSortDialog(context, podcastProvider);
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
              actions: [
                PoddrAddSubscriptionBtn(rss: rss),
                PoddrIconButton(
                  icon: const Icon(LucideIcons.info),
                  onPressed: () {
                    showPoddrDialog(
                      context: context,
                      builder: (dialogContext) {
                        return PoddrDialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                podcastProvider.podcast?.title ?? "Podcast",
                                style: context.theme.textTheme.headlineSmall,
                              ),
                              PoddrHTML(
                                  html: podcastProvider.podcast?.description ??
                                      ""),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          child: podcastProvider.isLoading || podcastProvider.podcast != null
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      gapH8,
                      StreamBuilder<int?>(
                        stream: context
                            .read<SubscriptionProvider>()
                            .watchSubscriptionId(rss),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !snapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          final subscriptionId = snapshot.data;
                          if (subscriptionId == null) {
                            return const SizedBox.shrink();
                          }
                          return StreamBuilder<List<PodcastCollection>>(
                            stream: context
                                .read<CollectionsProvider>()
                                .watchCollectionsForSubscription(
                                    subscriptionId),
                            builder: (context, colSnapshot) {
                              final collections = colSnapshot.data ?? [];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: PoddrCollectionsDisplay(
                                          collections: collections),
                                    ),
                                    gapW8,
                                    PoddrCollectionLinkButton(
                                        subscriptionId: subscriptionId),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      gapH8,
                      if (podcastProvider.isLoading)
                        const ShimmerLoadingList(height: 48)
                      else
                        PoddrBox(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: podcastProvider.episodes.length,
                            itemBuilder: (context, index) {
                              return Episode(
                                  episode: podcastProvider.episodes[index]);
                            },
                          ),
                        ),
                      const BottomPaddingFix(),
                    ],
                  ),
                )
              : const EmptyState(
                  icon: LucideIcons.podcast,
                  title: 'Podcast not found',
                  subtitle: 'This podcast could not be loaded',
                ),
        );
      },
    );
  }

  void _showFilterSortDialog(BuildContext context, PodcastViewModel viewModel) {
    showPoddrDialog(
      context: context,
      builder: (dialogContext) {
        return ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) {
            return PoddrDialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PoddrTextInput(
                    controller: viewModel.filterController,
                    hintText: "Type to filter episodes...",
                    onChanged: (value) {
                      viewModel.setFilter(value);
                    },
                    suffixIcon: viewModel.filter.isNotEmpty
                        ? PoddrIconButton(
                            icon: const Icon(LucideIcons.x),
                            size: 20,
                            onPressed: () {
                              viewModel.setFilter('');
                            },
                          )
                        : null,
                  ),
                  gapH16,
                  for (var field in EpisodeSortField.values)
                    PoddrListTile(
                      leading: Icon(
                        viewModel.sortField == field.label
                            ? LucideIcons.circleDot
                            : LucideIcons.circle,
                        size: 18,
                        color: context.theme.secondary,
                      ),
                      title: field.label,
                      onTap: () {
                        viewModel.setSort(field: field);
                      },
                    ),
                  PoddrIconButton(
                    icon: viewModel.sortDirection == "Ascending"
                        ? const Icon(LucideIcons.arrowUp, size: 20)
                        : const Icon(LucideIcons.arrowDown, size: 20),
                    onPressed: () {
                      viewModel.setSort(
                        direction: viewModel.sortDirection == "Ascending"
                            ? SortDirection.descending
                            : SortDirection.ascending,
                      );
                    },
                  ),
                ],
              ),
            );
          },
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
    final podcastProvider = context.read<PodcastViewModel>();

    final isCurrentEpisode =
        context.select<MediaProvider, bool>((mediaProvider) {
      return mediaProvider.episodeTitle == episode.title;
    });

    return PoddrListItem(
      title: episode.title,
      subtitle: convertDateToString(episode.publicationDate),
      isActive: isCurrentEpisode,
      actions: [
        Text(
          convertDurationToString(
            episode.duration,
          ),
          maxLines: 1,
          style: context.theme.textTheme.labelMedium.copyWith(
            color: isCurrentEpisode
                ? context.theme.onSurface
                : context.theme.onSurfaceVariant,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PoddrIconButton(
          icon: const Icon(
            LucideIcons.info,
          ),
          onPressed: () {
            showPoddrDialog(
              context: context,
              builder: (dialogContext) {
                return PoddrDialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode.title ?? '',
                        style: context.theme.textTheme.headlineSmall,
                      ),
                      gapH16,
                      PoddrHTML(html: episode.description ?? ''),
                    ],
                  ),
                );
              },
            );
          },
        ),
        PoddrIconButton(
          onPressed: () {
            context.read<MediaProvider>().addToQueue(
                  audioUrl: episode.audioUrl,
                  videoUrl: episode.videoUrl,
                  episodeTitle: episode.title,
                  podcastTitle: episode.podcastTitle,
                  podcastRSS: podcastProvider.podcast!.rss ?? "Missing RSS",
                  description: episode.description,
                  artUri: podcastProvider.podcast!.image,
                  album: episode.title,
                  artist: podcastProvider.podcast!.author,
                );
          },
          icon: const Icon(
            LucideIcons.listMusic,
          ),
        ),
        EpisodeHistoryCircle(
          audioUrl: episode.audioUrl,
          size: 18,
        ),
        DownloadButton(episode: episode),
      ],
      onTap: () {
        context.read<MediaProvider>().loadMedia(
              audioUrl: episode.audioUrl,
              videoUrl: episode.videoUrl,
              episodeTitle: episode.title,
              podcastTitle: episode.podcastTitle,
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
