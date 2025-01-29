import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/components/ui/add_fav_btn.dart';
import 'package:poddr/components/ui/appbar.dart';
import 'package:poddr/components/ui/appbar_options.dart';
import 'package:poddr/components/ui/dropdown.dart';
import 'package:poddr/components/ui/grid_item.dart';
import 'package:poddr/components/ui/image.dart';
import 'package:poddr/components/ui/list_item.dart';
import 'package:poddr/providers/podcast_discovery.dart';
import 'package:poddr/utils/itunes_countries.dart';
import 'package:poddr/utils/itunes_genres.dart';
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          PoddrAppBar(
            title: Text(
              'Discover',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 28,
              ),
            ),
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
          const DiscoveryGrid(),
          const DiscoveryList(),
        ],
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
    final items = charts.charts.items;

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
                imageUri: Uri.parse(podcast.artworkUrl100 ?? ""),
              ),
              title: podcast.artistName ?? "",
              subtitle: podcast.trackName ?? "",
              onTap: () {
                context.push('/podcast?rss=${podcast.feedUrl}');
              },
              actions: [
                PoddrAddFavBtn(
                  title: podcast.trackName ?? "",
                  description: podcast.artistName ?? "",
                  author: podcast.artistName ?? "",
                  image: podcast.artworkUrl600 ?? "",
                  rss: podcast.feedUrl ?? "",
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
    final items = charts.charts.items;

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
            title: podcast.collectionName ?? "",
            subtitle: podcast.trackName ?? "",
            imageUri: Uri.parse(podcast.artworkUrl600 ?? ""),
            onTap: () {
              context.push('/podcast?rss=${podcast.feedUrl}');
            },
            actions: [
              PoddrAddFavBtn(
                title: podcast.trackName ?? "",
                description: podcast.artistName ?? "",
                author: podcast.artistName ?? "",
                image: podcast.artworkUrl600 ?? "",
                rss: podcast.feedUrl ?? "",
              ),
            ],
          );
        },
        itemCount: items.length,
      ),
    );
  }
}
