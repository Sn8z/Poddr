import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/widgets/add_subscription_btn.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
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

        return PageLayout(
          header: Container(
            padding: const EdgeInsets.all(8),
            color: context.theme.surfaceContainerHigh,
            child: PoddrTextInput(
              hintText: 'Search',
              onSubmit: (value) {
                searchProvider.searchPodcast(value);
              },
            ),
          ),
          children: [
            gapH16,
            searchProvider.isLoading ? const LoadingBox() : const ResultBox(),
            const BottomPaddingFix(),
          ],
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
    final searchResults = context.watch<SearchViewModel>().searchResults;

    if (searchResults.isEmpty) {
      return ContentBox(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "No results",
              style: TextStyle(
                color: context.theme.onSurface,
              ),
            ),
          ),
        ],
      );
    }

    return ContentBox(
      children: searchResults.map((result) {
        return PoddrListItem(
          leading: Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: PoddrImage(imageUrl: result.image ?? ''),
          ),
          title: result.title,
          subtitle: result.author,
          onTap: () {
            final rss = Uri.encodeComponent(result.rss ?? '');
            context.push('/podcasts/$rss');
          },
          actions: [
            PoddrAddSubscriptionBtn(rss: result.rss),
          ],
        );
      }).toList(),
    );
  }
}
