import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/widgets/add_subscription_btn.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/services/search.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:provider/provider.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchProvider(),
      builder: (context, child) {
        final searchProvider = context.watch<SearchProvider>();

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: false,
                  pinned: true,
                  snap: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  toolbarHeight: 82,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  surfaceTintColor: Theme.of(context).colorScheme.primary,
                  title: PoddrTextInput(
                    hintText: 'Search',
                    onSubmit: (value) {
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
          ),
        );
      },
    );
  }
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
    final searchResults = context.watch<SearchProvider>().searchResults;

    if (searchResults.isEmpty) {
      return const ContentBox(
        children: [
          ListTile(
            title: Text("No results"),
          ),
        ],
      );
    }

    return DecoratedSliver(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
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
