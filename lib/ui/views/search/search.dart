import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
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
                    onFieldSubmitted: (value) {
                      searchProvider.searchPodcast(value);
                    },
                  ),
                ),
                searchProvider.isSearching
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
    return const SearchBox(
      title: "Searching...",
      children: [
        ListTile(
          title: ShimmerBox(),
        ),
        ListTile(
          title: ShimmerBox(),
        ),
        ListTile(
          title: ShimmerBox(),
        ),
      ],
    );
  }
}

class ResultBox extends StatelessWidget {
  const ResultBox({super.key});

  @override
  Widget build(BuildContext context) {
    final searchResults = context.watch<SearchProvider>().searchResults;

    if (searchResults.isEmpty) {
      return const SearchBox(
        children: [
          ListTile(
            title: Text("No results"),
          ),
        ],
      );
    }

    return SearchBox(
      title: "Podcasts",
      children: searchResults
          .map(
            (e) => PoddrListItem(
              leading: PoddrImage(imageUri: Uri.parse(e.image ?? '')),
              title: e.title ?? '',
              subtitle: e.rss ?? '',
              onTap: () {
                context.push('/podcasts/details?rss=${e.rss}');
              },
            ),
          )
          .toList(),
    );
  }
}

class SearchBox extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SearchBox({
    super.key,
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(
                title ?? '',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            if (title != null) gapH8,
            ...children,
          ],
        ),
      ),
    );
  }
}
