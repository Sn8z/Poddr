import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/widgets/add_fav_btn.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/dropdown.dart';
import 'package:poddr/ui/components/widgets/grid_item.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/services/podcast_discovery.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/utils/itunes_countries.dart';
import 'package:poddr/ui/utils/itunes_genres.dart';
import 'package:provider/provider.dart';

class PodcastDiscoveryView extends StatelessWidget {
  const PodcastDiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PodcastDiscoveryProvider(),
      child: const _PodcastDiscoveryViewContent(),
    );
  }
}

class _PodcastDiscoveryViewContent extends StatelessWidget {
  const _PodcastDiscoveryViewContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            PoddrAppBar(
              title: "Podcasts",
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.grid_view_rounded),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.view_list_rounded),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.sign_language_rounded),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.pin_drop_outlined),
                ),
              ],
            ),
            PoddrAppBarOptions(
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PoddrDropDown(
                    initialSelection:
                        context.read<PodcastDiscoveryProvider>().country,
                    items: itunesCountries.map((e) {
                      return DropdownMenuEntry(
                        value: e['code'] ?? "",
                        label: e['name'] ?? "",
                      );
                    }).toList(),
                    onSelected: (value) {
                      debugPrint(value);
                      context
                          .read<PodcastDiscoveryProvider>()
                          .setCountry(value ?? '');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PoddrDropDown(
                    initialSelection:
                        context.read<PodcastDiscoveryProvider>().genre,
                    items: podcastGenres.map((e) {
                      return DropdownMenuEntry(
                        value: e['id'] ?? "",
                        label: e['genre'] ?? "",
                      );
                    }).toList(),
                    onSelected: (value) {
                      debugPrint(value);
                      context
                          .read<PodcastDiscoveryProvider>()
                          .setGenre(value ?? '');
                    },
                  ),
                ),
              ],
            ),
            sliverGapH8,
            SliverToBoxAdapter(
              child: Text(
                "Trending",
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    20,
                    (index) => Container(
                      width: 160,
                      height: 160,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "Item $index",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            sliverGapH8,
            SliverToBoxAdapter(
              child: Text(
                "Poddr Picks",
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: CarouselView(
                  itemExtent: 160,
                  shrinkExtent: 80,
                  children: List.generate(
                      20,
                      (index) => Container(
                            width: double.infinity,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Item $index",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )),
                ),
              ),
            ),
            sliverGapH8,
            SliverToBoxAdapter(
              child: Text(
                "New Releases",
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            sliverGapH8,
            SliverToBoxAdapter(
              child: Text(
                "Continue listening",
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            sliverGapH8,
            const DiscoveryGrid(),
            const DiscoveryList(),
          ],
        ),
      ),
    );
  }
}

class DiscoveryList extends StatelessWidget {
  const DiscoveryList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final charts = context.watch<PodcastDiscoveryProvider>();
    final isLoading = charts.isLoading;
    final items = charts.charts;

    if (isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final podcast = items[index];

            return PoddrListItem(
              leading: PoddrImage(
                imageUri: Uri.parse(podcast.image ?? ''),
              ),
              title: podcast.title ?? '',
              subtitle: podcast.title ?? '',
              onTap: () {
                context.push('/podcasts/details?rss=${podcast.rss}');
              },
              actions: [
                PoddrAddFavBtn(
                  title: podcast.title ?? '',
                  description: podcast.description ?? '',
                  author: podcast.author ?? '',
                  image: podcast.image ?? '',
                  rss: podcast.rss ?? '',
                ),
              ],
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

class DiscoveryGrid extends StatelessWidget {
  const DiscoveryGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final charts = context.watch<PodcastDiscoveryProvider>();
    final isLoading = charts.isLoading;
    final items = charts.charts;

    if (isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 280,
          mainAxisSpacing: 32,
          crossAxisSpacing: 32,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final podcast = items[index];

          return PoddrGridItem(
            title: podcast.title ?? '',
            subtitle: podcast.title ?? '',
            imageUri: Uri.parse(podcast.image ?? ''),
            onTap: () {
              context.push('/podcasts/details?rss=${podcast.rss}');
            },
            actions: [
              PoddrAddFavBtn(
                title: podcast.title ?? '',
                description: podcast.description ?? '',
                author: podcast.author ?? '',
                image: podcast.image ?? '',
                rss: podcast.rss ?? '',
              ),
            ],
          );
        },
        itemCount: items.length,
      ),
    );
  }
}
