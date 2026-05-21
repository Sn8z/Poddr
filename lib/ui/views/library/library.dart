import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_list.dart';
import 'package:poddr/ui/components/widgets/empty_state.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/components/widgets/library_nav.dart';
import 'package:poddr/ui/layouts/page_layout.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/utils/sort_fields.dart';
import 'package:poddr/ui/components/widgets/collection_filter_list.dart';
import 'package:poddr/ui/views/library/library_view_model.dart';
import 'package:poddr/ui/components/navigation/destinations.dart';
import 'package:provider/provider.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider2<SubscriptionProvider,
        CollectionsProvider, LibraryViewModel>(
      create: (context) => LibraryViewModel(
        context.read<SubscriptionProvider>(),
        context.read<CollectionsProvider>(),
      ),
      update: (_, subscription, collections, previous) =>
          previous ?? LibraryViewModel(subscription, collections),
      builder: (context, child) {
        final viewModel = context.watch<LibraryViewModel>();
        final isDesktop =
            MediaQuery.sizeOf(context).width > Breakpoints.tabletScreen;

        return PageLayout(
          header: PoddrAppBar(
            title: const Text('Subscriptions'),
            actions: isDesktop
                ? [
                    PoddrLibraryNav(
                      currentRoute: '/library/subscriptions',
                      segments: librarySubNav
                          .map((item) => LibrarySegment.fromNavItem(item))
                          .toList(),
                    ),
                  ]
                : null,
            bottom: PoddrAppBarOptions(
              title: isDesktop
                  ? Row(
                      children: [
                        PoddrIconButton(
                          icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01),
                          size: 20,
                          onPressed: () {
                            _showFilterSortDialog(context, viewModel);
                          },
                        ),
                        gapW8,
                        Expanded(
                          child: PoddrTextInput(
                            controller: viewModel.filterController,
                            hintText: "Type to filter podcasts...",
                            onChanged: (value) {
                              viewModel.setFilter(value);
                            },
                            suffixIcon: viewModel.filter.isNotEmpty
                                ? PoddrIconButton(
                                    icon: HugeIcon(
                                        icon: HugeIcons.strokeRoundedCancel01),
                                    size: 20,
                                    onPressed: () {
                                      viewModel.setFilter('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        PoddrIconButton(
                          icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01),
                          size: 20,
                          onPressed: () {
                            _showFilterSortDialog(context, viewModel);
                          },
                        ),
                      ],
                    ),
              actions: isDesktop
                  ? []
                  : [
                      PoddrLibraryNav(
                        currentRoute: '/library/subscriptions',
                        segments: librarySubNav
                            .map((item) => LibrarySegment.fromNavItem(item))
                            .toList(),
                      ),
                    ],
            ),
          ),
          child: viewModel.isLoading
              ? const ShimmerLoadingList()
              : viewModel.subscriptions.isEmpty
                  ? EmptyState(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedPodcast,
                        size: 64,
                        color: context.theme.secondary,
                      ),
                      title: 'No subscriptions yet',
                      subtitle: 'Subscribe to podcasts to see them here',
                    )
                  : CustomScrollView(
                      slivers: [
                        sliverGapH16,
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final Podcast podcast =
                                    viewModel.subscriptions[index];
                                return PoddrListItem(
                                  title: podcast.title ?? 'Missing Title',
                                  subtitle: podcast.author ?? 'Missing Author',
                                  onTap: () {
                                    final rss =
                                        Uri.encodeComponent(podcast.rss ?? '');
                                    context.push('/podcasts/$rss');
                                  },
                                  leading: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: PoddrImage(
                                      imageUrl: podcast.image ?? '',
                                      fit: BoxFit.cover,
                                      maxHeightDiskCache: 300,
                                    ),
                                  ),
                                  actions: [
                                    PoddrIconButton(
                                      onPressed: () {},
                                      icon: HugeIcon(
                                          icon: HugeIcons
                                              .strokeRoundedMoreVertical),
                                    ),
                                  ],
                                );
                              },
                              childCount: viewModel.subscriptions.length,
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

  void _showFilterSortDialog(BuildContext context, LibraryViewModel viewModel) {
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
                    hintText: "Type to filter podcasts...",
                    onChanged: (value) {
                      viewModel.setFilter(value);
                    },
                    suffixIcon: viewModel.filter.isNotEmpty
                        ? PoddrIconButton(
                            icon:
                                HugeIcon(icon: HugeIcons.strokeRoundedCancel01),
                            size: 20,
                            onPressed: () {
                              viewModel.setFilter('');
                            },
                          )
                        : null,
                  ),
                  gapH16,
                  for (var field in PodcastSortField.values)
                    PoddrListTile(
                      leading: HugeIcon(
                        icon: viewModel.sortField == field.label
                            ? HugeIcons.strokeRoundedCheckmarkCircle01
                            : HugeIcons.strokeRoundedCircle,
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
                        ? HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowUp01, size: 20)
                        : HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowDown01, size: 20),
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
