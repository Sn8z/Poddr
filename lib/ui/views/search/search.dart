import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/widgets/add_subscription_btn.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/components/widgets/poddr_list.dart';
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

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchAppBarDelegate(
                  onSearch: (value) {
                    searchProvider.searchPodcast(value);
                  },
                ),
              ),
              sliverGapH16,
              searchProvider.isLoading
                  ? const LoadingBox()
                  : const ResultBox(),
              const BottomPaddingFix(),
            ],
          ),
        );
      },
    );
  }
}

class _SearchAppBarDelegate extends SliverPersistentHeaderDelegate {
  final ValueChanged<String> onSearch;

  _SearchAppBarDelegate({required this.onSearch});

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: PoddrTextInput(
        hintText: 'Search',
        onSubmit: onSearch,
      ),
    );
  }

  @override
  double get maxExtent => 82;

  @override
  double get minExtent => 82;

  @override
  bool shouldRebuild(_SearchAppBarDelegate oldDelegate) => false;
}

class LoadingBox extends StatelessWidget {
  const LoadingBox({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentBox(
      children: List.generate(5, (index) {
        return const PoddrListItem(
          data: ShimmerBox(
            height: 36,
          ),
        );
      }),
    );
  }
}

class ResultBox extends StatelessWidget {
  const ResultBox({super.key});

  @override
  Widget build(BuildContext context) {
    final searchResults = context.watch<SearchViewModel>().searchResults;

    if (searchResults.isEmpty) {
      return const ContentBox(
        children: [
          PoddrListTile(title: "No results",
          ),
        ],
      );
    }

    return DecoratedSliver(
      decoration: BoxDecoration(
        color: context.theme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      sliver: SliverList.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          return PoddrListItem(
            leading: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: PoddrImage(imageUrl: searchResults[index].image ?? ''),
            ),
            title: searchResults[index].title,
            subtitle: searchResults[index].author,
            onTap: () {
              final rss = Uri.encodeComponent(searchResults[index].rss ?? '');
              context.push('/podcasts/$rss');
            },
            actions: [
              PoddrAddSubscriptionBtn(rss: searchResults[index].rss),
            ],
          );
        },
      ),
    );
  }
}
