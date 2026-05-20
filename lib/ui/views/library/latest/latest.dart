import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/components/widgets/download_button.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/components/widgets/poddr_list.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/empty_state.dart';
import 'package:poddr/ui/layouts/page_layout.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/utils/string_converter.dart';
import 'package:poddr/ui/utils/sort_fields.dart';
import 'package:poddr/ui/components/widgets/collection_filter_list.dart';
import 'package:poddr/ui/views/library/latest/latest_view_model.dart';
import 'package:provider/provider.dart';

class LatestEpisodesView extends StatelessWidget {
  const LatestEpisodesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider2<SubscriptionProvider,
        CollectionsProvider, LatestEpisodesViewModel>(
      create: (context) => LatestEpisodesViewModel(
        context.read<SubscriptionProvider>(),
        context.read<CollectionsProvider>(),
      ),
      update: (context, source, collections, previous) =>
          previous ?? LatestEpisodesViewModel(source, collections),
      builder: (context, child) {
        final viewModel = context.watch<LatestEpisodesViewModel>();

        return PageLayout(
          header: PoddrAppBar(
            title: const Text('Latest Episodes'),
            actions: [
              PoddrOutlinedButton(
                child: const Text("Library"),
                onPressed: () => context.push("/library"),
              ),
              gapW8,
              PoddrOutlinedButton(
                child: const Text("Downloads"),
                onPressed: () => context.push("/library/downloads"),
              ),
            ],
            bottom: PoddrAppBarOptions(
              title: LayoutBuilder(
                builder: (layoutContext, constraints) {
                  if (constraints.maxWidth > Breakpoints.tabletScreen) {
                    return Row(
                      children: [
                        PoddrIconButton(
                          icon: const Icon(LucideIcons.filter),
                          onPressed: () {
                            _showFilterSortDialog(context, viewModel);
                          },
                        ),
                        gapW8,
                        Expanded(
                          child: PoddrTextInput(
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
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        PoddrIconButton(
                          icon: const Icon(LucideIcons.filter),
                          onPressed: () {
                            _showFilterSortDialog(context, viewModel);
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          child: viewModel.episodes.isEmpty
              ? const EmptyState(
                  icon: LucideIcons.rss,
                  title: 'No episodes yet',
                  subtitle:
                      'New episodes from your subscriptions will appear here',
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      gapH16,
                      ContentBox(
                        children: [
                          for (var episode in viewModel.episodes)
                            PoddrListItem(
                              title: episode.title,
                              subtitle: episode.author,
                              leading: Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                child: PoddrImage(
                                    imageUrl: episode.imageUrl ?? ''),
                              ),
                              onTap: () {
                                context.read<MediaProvider>().loadMedia(
                                      album: episode.podcastTitle,
                                      podcastTitle: episode.podcastTitle,
                                      episodeTitle: episode.title,
                                      artist: episode.author,
                                      description: episode.description,
                                      audioUrl: episode.audioUrl,
                                      videoUrl: episode.videoUrl,
                                      podcastRSS: episode.podcastRSS,
                                      artUri: episode.imageUrl,
                                    );
                              },
                              actions: [
                                Text(convertDurationToString(episode.duration),
                                    style: context.theme.textTheme.bodySmall),
                                EpisodeHistoryCircle(
                                    audioUrl: episode.audioUrl),
                                DownloadButton(episode: episode),
                              ],
                            ),
                        ],
                      ),
                      const BottomPaddingFix(),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _showFilterSortDialog(
      BuildContext context, LatestEpisodesViewModel viewModel) {
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
                  gapH16,
                  Text("Collections",
                      style: dialogContext.theme.textTheme.titleSmall),
                  gapH8,
                  PoddrCollectionFilterList(
                    selectedCollectionIds: viewModel.selectedCollectionIds,
                    onCollectionChanged: (ids) {
                      viewModel.setCollectionFilter(ids);
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
