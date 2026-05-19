import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/widgets/add_subscription_btn.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/empty_state.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/layouts/page_layout.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
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
          header: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: context.theme.surfaceContainerHigh,
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            child: PoddrTextInput(
              hintText: 'Search',
              fontSize: 18,
              onSubmit: (value) {
                searchProvider.searchPodcast(value);
              },
            ),
          ),
          child: searchProvider.isLoading
              ? const ShimmerLoadingList()
              : searchResults.isEmpty
                  ? const EmptyState(
                      icon: LucideIcons.search,
                      title: 'No results found',
                      subtitle: 'Try searching for a different term',
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          gapH16,
                          ContentBox(
                            children: searchResults.map((result) {
                              return PoddrListItem(
                                leading: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child:
                                      PoddrImage(imageUrl: result.image ?? ''),
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
                            }).toList(),
                          ),
                          const BottomPaddingFix(),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}


