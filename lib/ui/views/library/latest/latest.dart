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
                        Expanded(
                          child: PoddrTextInput(
                            hintText: "Type to filter episodes...",
                            onChanged: (value) {
                              viewModel.setFilter(value);
                            },
                            suffixIcon: PoddrIconButton(
                              icon: const Icon(LucideIcons.x),
                              size: 20,
                              onPressed: () {
                                viewModel.setFilter('');
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PoddrElevatedButton(
                          child: Text(viewModel.sortField),
                          onPressed: () {
                            _showSortDialog(context, viewModel);
                          },
                        ),
                        const SizedBox(width: 8),
                        PoddrIconButton(
                          icon: viewModel.sortDirection == "Ascending"
                              ? const Icon(LucideIcons.arrowUp)
                              : const Icon(LucideIcons.arrowDown),
                          onPressed: () {
                            viewModel.setSort(
                              direction: viewModel.sortDirection == "Ascending"
                                  ? SortDirection.descending
                                  : SortDirection.ascending,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _LatestCollectionFilterButton(viewModel: viewModel),
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

  void _showSortDialog(
      BuildContext context, LatestEpisodesViewModel viewModel) {
    showPoddrDialog(
      context: context,
      builder: (dialogContext) {
        return PoddrDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var field in EpisodeSortField.values)
                PoddrListTile(
                  title: field.label,
                  trailing: viewModel.sortField == field.label
                      ? const Icon(LucideIcons.check, size: 18)
                      : null,
                  onTap: () {
                    viewModel.setSort(field: field);
                  },
                ),
            ],
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
                  Text("Filter & Sort",
                      style: dialogContext.theme.textTheme.titleMedium),
                  gapH16,
                  PoddrTextInput(
                    labelText: "Search",
                    hintText: "Type to filter episodes...",
                    initialValue: viewModel.filter,
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
                  Text("Sort by",
                      style: dialogContext.theme.textTheme.titleSmall),
                  gapH8,
                  for (var field in EpisodeSortField.values)
                    PoddrListTile(
                      title: field.label,
                      trailing: viewModel.sortField == field.label
                          ? const Icon(LucideIcons.check, size: 18)
                          : null,
                      onTap: () {
                        viewModel.setSort(field: field);
                      },
                    ),
                  gapH16,
                  Text("Direction",
                      style: dialogContext.theme.textTheme.titleSmall),
                  gapH8,
                  Row(
                    children: [
                      Expanded(
                        child: viewModel.sortDirection == "Ascending"
                            ? PoddrFilledButton(
                                onPressed: () {},
                                child: const Text("Ascending"),
                              )
                            : PoddrOutlinedButton(
                                onPressed: () {
                                  viewModel.setSort(
                                      direction: SortDirection.ascending);
                                },
                                child: const Text("Ascending"),
                              ),
                      ),
                      gapW8,
                      Expanded(
                        child: viewModel.sortDirection == "Descending"
                            ? PoddrFilledButton(
                                onPressed: () {},
                                child: const Text("Descending"),
                              )
                            : PoddrOutlinedButton(
                                onPressed: () {
                                  viewModel.setSort(
                                      direction: SortDirection.descending);
                                },
                                child: const Text("Descending"),
                              ),
                      ),
                    ],
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
                  gapH16,
                  PoddrFilledButton(
                    child: const Text("Done"),
                    onPressed: () => Navigator.pop(dialogContext),
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

class _LatestCollectionFilterButton extends StatelessWidget {
  final LatestEpisodesViewModel viewModel;

  const _LatestCollectionFilterButton({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final selected = viewModel.selectedCollectionIds;
        final label = selected.isEmpty
            ? "All collections"
            : "${selected.length} collection${selected.length == 1 ? '' : 's'}";

        return PoddrOutlinedButton(
          child: Text(label),
          onPressed: () {
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
                          Text("Filter by collection",
                              style: dialogContext.theme.textTheme.titleMedium),
                          gapH16,
                          PoddrCollectionFilterList(
                            selectedCollectionIds:
                                viewModel.selectedCollectionIds,
                            onCollectionChanged: (ids) {
                              viewModel.setCollectionFilter(ids);
                            },
                          ),
                          gapH16,
                          PoddrFilledButton(
                            child: const Text("Done"),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
