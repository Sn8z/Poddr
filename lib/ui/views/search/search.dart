import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/add_subscription_btn.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/empty_state.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/layouts/page_layout.dart';
import 'package:poddr/ui/views/search/search_view_model.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:provider/provider.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchViewModel(),
      builder: (context, child) {
        final searchProvider = context.watch<SearchViewModel>();
        final searchResults = searchProvider.searchResults;

        return PageLayout(
          slivers: [
            PoddrAppBar(
              title: PoddrTextInput(
                hintText: 'Search',
                fontSize: 16,
                onSubmit: (value) {
                  searchProvider.searchPodcast(value);
                },
              ),
            ),
            ...searchProvider.isLoading
              ? [const SliverToBoxAdapter(child: ShimmerLoadingList())]
              : searchResults.isEmpty
                  ? [
                      SliverToBoxAdapter(
                        child: EmptyState(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedSearch01,
                            size: 64,
                            color: context.theme.secondary,
                          ),
                          title: 'No results found',
                          subtitle: 'Try searching for a different term',
                        ),
                      ),
                    ]
                  : [
                      sliverGapH16,
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final result = searchResults[index];
                              return PoddrListItem(
                                leading: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: PoddrImage(
                                      imageUrl: result.image ?? '',
                                      maxHeightDiskCache: 300),
                                ),
                                title: result.title,
                                subtitle: result.author,
                                onTap: () {
                                  final rss =
                                      Uri.encodeComponent(result.rss ?? '');
                                  context.push('/podcasts/$rss');
                                },
                                actions: [
                                  PoddrAddSubscriptionBtn(rss: result.rss),
                                ],
                              );
                            },
                            childCount: searchResults.length,
                          ),
                        ),
                      ),
                    ],
                  ],
        );
      },
    );
  }
}
