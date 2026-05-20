import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/services/offline.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/download_button.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/library_nav.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_list.dart';
import 'package:poddr/ui/components/widgets/poddr_confirm_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/empty_state.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/layouts/page_layout.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/utils/sort_fields.dart';
import 'package:poddr/ui/utils/string_converter.dart';
import 'package:poddr/ui/components/widgets/collection_filter_list.dart';
import 'package:poddr/ui/views/library/downloads/downloads_view_model.dart';
import 'package:provider/provider.dart';

class DownloadsView extends StatelessWidget {
  const DownloadsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider4<OfflineProvider, MediaProvider,
        SubscriptionProvider, CollectionsProvider, DownloadsViewModel>(
      create: (context) => DownloadsViewModel(
        context.read<OfflineProvider>(),
        context.read<MediaProvider>(),
        context.read<SubscriptionProvider>(),
        context.read<CollectionsProvider>(),
      ),
      update: (_, offline, media, subscriptions, collections, previous) =>
          previous ??
          DownloadsViewModel(offline, media, subscriptions, collections),
      builder: (context, child) {
        final viewModel = context.watch<DownloadsViewModel>();
        final downloads = viewModel.downloads;
        final isDesktop = MediaQuery.sizeOf(context).width > Breakpoints.tabletScreen;

        return PageLayout(
          header: PoddrAppBar(
            title: const Text('Downloads'),
            actions: isDesktop
                ? [
                    PoddrLibraryNav(
                      currentRoute: '/library/downloads',
                      segments: const [
                        LibrarySegment(
                          label: 'Subscriptions',
                          icon: LucideIcons.library,
                          route: '/library/subscriptions',
                        ),
                        LibrarySegment(
                          label: 'Latest',
                          icon: LucideIcons.clock,
                          route: '/library/latest',
                        ),
                        LibrarySegment(
                          label: 'Downloads',
                          icon: LucideIcons.download,
                          route: '/library/downloads',
                        ),
                      ],
                    ),
                  ]
                : null,
            bottom: PoddrAppBarOptions(
              title: isDesktop
                  ? Row(
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
                            hintText: "Type to filter downloads...",
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
                        gapW8,
                        PoddrOutlinedButton(
                          child: Text("Clear all"),
                          onPressed: () {
                            _showClearAllDialog(context, viewModel);
                          },
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        PoddrIconButton(
                          icon: const Icon(LucideIcons.filter),
                          onPressed: () {
                            _showFilterSortDialog(context, viewModel);
                          },
                        ),
                        const Spacer(),
                        PoddrOutlinedButton(
                          child: Text("Clear all"),
                          onPressed: () {
                            _showClearAllDialog(context, viewModel);
                          },
                        ),
                      ],
                    ),
              actions: isDesktop
                  ? []
                  : [
                      PoddrLibraryNav(
                        currentRoute: '/library/downloads',
                        segments: const [
                          LibrarySegment(
                            label: 'Subscriptions',
                            icon: LucideIcons.library,
                            route: '/library/subscriptions',
                          ),
                          LibrarySegment(
                            label: 'Latest',
                            icon: LucideIcons.clock,
                            route: '/library/latest',
                          ),
                          LibrarySegment(
                            label: 'Downloads',
                            icon: LucideIcons.download,
                            route: '/library/downloads',
                          ),
                        ],
                      ),
                    ],
            ),
          ),
          child: viewModel.isLoading
              ? const ShimmerLoadingList()
              : downloads.isEmpty
                  ? const EmptyState(
                      icon: LucideIcons.download,
                      title: 'No downloads yet',
                      subtitle: 'Download episodes to listen offline',
                    )
                  : CustomScrollView(
                      slivers: [
                        sliverGapH16,
                        if (downloads.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12, bottom: 8),
                              child: Text(
                                "Episodes (${downloads.length})",
                                style: context.theme.textTheme.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.theme.primary,
                                ),
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.all(12),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final download = downloads[index];
                                return PoddrListItem(
                                  title: download.title,
                                  subtitle: download.podcastTitle,
                                  leading: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                    ),
                                    child: PoddrImage(
                                        imageUrl: download.imageUrl,
                                        maxHeightDiskCache: 300),
                                  ),
                                  onTap: () {
                                    viewModel.loadMedia(
                                      audioUrl: download.audioUrl,
                                      videoUrl: download.videoUrl,
                                      episodeTitle: download.title,
                                      podcastTitle: download.podcastTitle,
                                      podcastRSS: download.podcastRSS,
                                      description: download.description,
                                      artUri: download.imageUrl,
                                      album: download.title,
                                      artist: download.podcastTitle,
                                    );
                                  },
                                  actions: [
                                    Text(
                                      convertDurationToString(
                                        Duration(seconds: download.duration),
                                      ),
                                      style: context.theme.textTheme.bodySmall,
                                    ),
                                    EpisodeHistoryCircle(
                                        audioUrl: download.audioUrl),
                                    DownloadButton(
                                      episode:
                                          viewModel.toPodcastEpisode(download)!,
                                    ),
                                  ],
                                );
                              },
                              childCount: downloads.length,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(child: BottomPaddingFix()),
                      ],
                    ),
        );
      },
    );
  }

  void _showFilterSortDialog(
      BuildContext context, DownloadsViewModel viewModel) {
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
                    hintText: "Type to filter downloads...",
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
                  for (var field in OfflineEpisodeSortField.values)
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

void _showClearAllDialog(BuildContext context, DownloadsViewModel viewModel) {
  showPoddrDialog(
    context: context,
    builder: (dialogContext) {
      return PoddrConfirmDialog(
        title: 'Clear all downloads?',
        message:
            'This will delete ${viewModel.downloads.length} downloaded episode(s).',
        confirmLabel: 'Delete all',
        onConfirm: () {
          viewModel.clearAllDownloads();
          Navigator.pop(dialogContext);
        },
      );
    },
  );
}
