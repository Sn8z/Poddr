import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/box.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_list.dart';
import 'package:poddr/ui/components/widgets/empty_state.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/layouts/page_layout.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/utils/sort_fields.dart';
import 'package:poddr/ui/components/widgets/collection_filter_list.dart';
import 'package:poddr/ui/views/library/library_view_model.dart';
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

        return PageLayout(
          header: PoddrAppBar(
            title: const Text('Library'),
            actions: [
              PoddrOutlinedButton(
                child: const Text("Latest Episodes"),
                onPressed: () => context.push("/library/latest"),
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
                            hintText: "Type to filter podcasts...",
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
          child: viewModel.isLoading
              ? const ShimmerLoadingList()
              : viewModel.subscriptions.isEmpty
                  ? const EmptyState(
                      icon: LucideIcons.podcast,
                      title: 'No subscriptions yet',
                      subtitle: 'Subscribe to podcasts to see them here',
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          gapH16,
                          PoddrBox(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: viewModel.subscriptions.length,
                              itemBuilder: (context, index) {
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
                                    ),
                                  ),
                                  actions: [
                                    PoddrIconButton(
                                      onPressed: () {},
                                      icon:
                                          const Icon(LucideIcons.moreVertical),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const BottomPaddingFix(),
                        ],
                      ),
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
                            icon: const Icon(LucideIcons.x),
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
