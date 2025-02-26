import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/services/favourites.dart';
import 'package:provider/provider.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final favouritesProvider = context.watch<FavouritesProvider>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        body: CustomScrollView(
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
            PoddrAppBarOptions(
              title: const PoddrTextInput(),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
            if (favouritesProvider.isLoading) ...[
              const SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                ),
              ),
            ] else if (favouritesProvider.favourites.isEmpty) ...[
              const SliverToBoxAdapter(
                child: Text('Your library is empty'),
              ),
            ] else ...[
              SliverList.builder(
                itemCount: favouritesProvider.favourites.length,
                itemBuilder: (context, index) {
                  return PoddrListItem(
                    title: favouritesProvider.favourites[index]['title'],
                    subtitle: favouritesProvider.favourites[index]['author'],
                    onTap: () {
                      context.push(
                          '/podcasts/details?rss=${favouritesProvider.favourites[index]['rss']}');
                    },
                    leading: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: PoddrImage(
                        imageUri: Uri.parse(
                            favouritesProvider.favourites[index]['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
