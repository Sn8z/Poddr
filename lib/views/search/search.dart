import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/components/ui/add_fav_btn.dart';
import 'package:poddr/components/ui/image.dart';
import 'package:poddr/components/ui/list_item.dart';
import 'package:poddr/components/ui/shimmer.dart';
import 'package:poddr/components/ui/text_input.dart';
import 'package:poddr/providers/search.dart';
import 'package:provider/provider.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchProvider(),
      child: const _SearchViewContent(),
    );
  }
}

class _SearchViewContent extends StatelessWidget {
  const _SearchViewContent();

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 80,
            title: PoddrTextInput(
              labelText: "Search",
              prefixIcon: const Icon(Icons.search),
              onFieldSubmitted: (String query) {
                searchProvider.searchPodcast(query);
              },
            ),
          ),
          if (searchProvider.isSearching)
            SliverList.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return const ListTile(
                  title: ShimmerBox(),
                );
              },
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = searchProvider.searchResults[index];
                  return PoddrListItem(
                    title: item.title ?? '',
                    subtitle: item.explicit.toString(),
                    leading: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: PoddrImage(
                        imageUri: Uri.parse(item.image ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                    onTap: () => context.push('/podcast?rss=${item.rss}'),
                    actions: [
                      PoddrAddFavBtn(
                        title: item.title ?? '',
                        rss: item.rss ?? '',
                        description: item.description ?? '',
                        author: item.author ?? '',
                        image: item.image ?? '',
                      ),
                    ],
                  );
                },
                childCount: searchProvider.searchResults.length,
              ),
            ),
        ],
      ),
    );
  }
}
