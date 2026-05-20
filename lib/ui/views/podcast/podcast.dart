import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/ui/components/widgets/add_subscription_btn.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/box.dart';
import 'package:poddr/ui/components/widgets/collections_section.dart';
import 'package:poddr/ui/components/widgets/download_button.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/html.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
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
import 'package:url_launcher/url_launcher.dart';

class PodcastDetailsView extends StatefulWidget {
  const PodcastDetailsView({super.key, required this.rss});
  final String rss;

  @override
  State<PodcastDetailsView> createState() => _PodcastDetailsViewState();
}

class _PodcastDetailsViewState extends State<PodcastDetailsView> {
  late final ValueNotifier<double> _shrinkRatioNotifier;

  @override
  void initState() {
    super.initState();
    _shrinkRatioNotifier = ValueNotifier<double>(0.0);
  }

  @override
  void dispose() {
    _shrinkRatioNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PodcastViewModel(initialRss: widget.rss),
      builder: (context, child) {
        final podcastProvider = context.watch<PodcastViewModel>();
        final podcast = podcastProvider.podcast;

        return PageLayout(
          shrinkRatioNotifier: _shrinkRatioNotifier,
          header: ListenableBuilder(
            listenable: _shrinkRatioNotifier,
            builder: (context, _) {
              return PodcastHeader(
                imageUrl: podcast?.image,
                title: podcast?.title,
                subtitle: podcast?.author,
                isLoading: podcastProvider.isLoading,
                metadata:
                    podcast != null ? _buildMetadataRow(context, podcast) : null,
                collections: CollectionsSection(rss: widget.rss),
                actions: [
                  PoddrAddSubscriptionBtn(rss: widget.rss),
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
                                  podcast?.title ?? "Podcast",
                                  style: context.theme.textTheme.headlineSmall,
                                ),
                                PoddrHTML(html: podcast?.description ?? ""),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  if (podcast?.link != null && podcast!.link!.isNotEmpty) ...[
                    PoddrIconButton(
                      icon: const Icon(LucideIcons.globe),
                      onPressed: () async {
                        final uri = Uri.parse(podcast.link ?? "");
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ],
                ],
                shrinkRatio: _shrinkRatioNotifier.value,
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
                ),
              );
            },
          ),
          child: podcastProvider.isLoading || podcastProvider.podcast != null
              ? CustomScrollView(
                  slivers: [
                    sliverGapH16,
                    if (podcastProvider.isLoading)
                      const SliverToBoxAdapter(
                        child: ShimmerLoadingList(height: 48),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Episode(
                                  episode: podcastProvider.episodes[index]);
                            },
                            childCount: podcastProvider.episodes.length,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(child: BottomPaddingFix()),
                  ],
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

  Widget _buildMetadataRow(BuildContext context, Podcast podcast) {
    final theme = context.theme;
    final items = <Widget>[];

    if (podcast.explicit) {
      items.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.secondaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'E',
            style: theme.textTheme.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.onSecondaryContainer,
            ),
          ),
        ),
      );
    }

    if (podcast.language != null && podcast.language!.isNotEmpty) {
      if (items.isNotEmpty) items.add(gapW8);
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.languages,
                size: 12, color: theme.onSurfaceVariant),
            gapW4,
            Text(
              podcast.language!.toUpperCase(),
              style: theme.textTheme.labelSmall.copyWith(
                color: theme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (podcast.episodes.isNotEmpty) {
      if (items.isNotEmpty) items.add(gapW8);
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.listTree, size: 12, color: theme.onSurfaceVariant),
            gapW4,
            Text(
              '${podcast.episodes.length} Episodes',
              style: theme.textTheme.labelSmall.copyWith(
                color: theme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (podcast.medium != null && podcast.medium!.isNotEmpty) {
      if (items.isNotEmpty) items.add(gapW8);
      items.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.tertiaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            capitalize(podcast.medium!),
            style: theme.textTheme.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.onTertiaryContainer,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: items,
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
