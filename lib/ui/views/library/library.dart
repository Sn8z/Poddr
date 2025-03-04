import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/services/favourites.dart';
import 'package:provider/provider.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController(
      initialPage: 0,
    );
    final favouritesProvider = context.watch<FavouritesProvider>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [
            PoddrAppBar(
              title: 'Library',
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            // if (favouritesProvider.isLoading) ...[
            //   const SliverToBoxAdapter(
            //     child: Center(
            //       child: CircularProgressIndicator(),
            //     ),
            //   ),
            //   const SliverToBoxAdapter(
            //     child: SizedBox(
            //       height: 100,
            //     ),
            //   ),
            // ] else if (favouritesProvider.favourites.isEmpty) ...[
            //   const SliverToBoxAdapter(
            //     child: Text('Your library is empty'),
            //   ),
            // ] else ...[
            //   SliverList.builder(
            //     itemCount: favouritesProvider.favourites.length,
            //     itemBuilder: (context, index) {
            //       return PoddrListItem(
            //         title: favouritesProvider.favourites[index]['title'],
            //         subtitle: favouritesProvider.favourites[index]['author'],
            //         onTap: () {
            //           context.push(
            //               '/podcasts/details?rss=${favouritesProvider.favourites[index]['rss']}');
            //         },
            //         leading: Container(
            //           clipBehavior: Clip.antiAlias,
            //           decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //           child: PoddrImage(
            //             imageUri: Uri.parse(
            //                 favouritesProvider.favourites[index]['image']),
            //             fit: BoxFit.cover,
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ],
            SliverAppBar(
              pinned: true,
              title: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  IconButton(
                    onPressed: () {
                      pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              child: PageView.custom(
                controller: pageController,
                childrenDelegate: SliverChildListDelegate(
                  [
                    const Text('Feed'),
                    const Text('Favourites'),
                    const Text('Offline'),
                  ],
                ),
              ),
            ),
            const BottomPaddingFix(),
          ],
        ),
      ),
    );
  }
}
