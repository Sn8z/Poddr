import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:poddr/components/audio/currently_playing.dart';
import 'package:poddr/components/ui/add_fav_btn.dart';
import 'package:poddr/components/ui/appbar_options.dart';
import 'package:poddr/components/ui/image.dart';
import 'package:poddr/components/ui/list_item.dart';
import 'package:poddr/components/ui/shimmer.dart';
import 'package:poddr/components/ui/text_input.dart';
import 'package:poddr/providers/media.dart';
import 'package:poddr/providers/podcast.dart';
import 'package:poddr/utils/string_converter.dart';
import 'package:poddr/utils/gaps.dart';
import 'package:provider/provider.dart';

class PodcastDetailsView extends StatelessWidget {
  const PodcastDetailsView({super.key, required this.rss});
  final String rss;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PodcastProvider(),
      child: PodcastDetailsViewContent(rss: rss),
    );
  }
}

class PodcastDetailsViewContent extends StatefulWidget {
  final String rss;

  const PodcastDetailsViewContent({
    super.key,
    required this.rss,
  });

  @override
  State<PodcastDetailsViewContent> createState() => _PodcastDetailsViewState();
}

class _PodcastDetailsViewState extends State<PodcastDetailsViewContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PodcastProvider>().getPodcast(widget.rss);
    });
  }

  @override
  Widget build(BuildContext context) {
    final podcastProvider = context.watch<PodcastProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PoddrImage(
                    imageUri: Uri.parse(podcastProvider.podcast?.image ?? ""),
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: PoddrImage(
                                imageUri: Uri.parse(
                                  podcastProvider.podcast?.image ?? "",
                                ),
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                            gapW16,
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    podcastProvider.podcast?.title ?? "",
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    podcastProvider.podcast?.description ?? "",
                                    maxLines: 3,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  gapH16,
                                  Text(
                                    "${podcastProvider.podcast?.episodes.length ?? 0} Episodes",
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            expandedHeight: 320,
            actions: [
              PoddrAddFavBtn(
                title: podcastProvider.podcast?.title ?? "",
                rss: podcastProvider.podcast?.url ?? "",
                description: podcastProvider.podcast?.description ?? "",
                author: podcastProvider.podcast?.title ?? "",
                image: podcastProvider.podcast?.image ?? "",
              ),
            ],
          ),
          PoddrAppBarOptions(
            title: const PoddrTextInput(),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search_rounded),
              ),
            ],
          ),
          if (podcastProvider.isLoading)
            SliverList.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return const ListTile(
                  title: ShimmerBox(),
                );
              },
            )
          else if (podcastProvider.podcast == null)
            const SliverFillRemaining(
              child: Text("No podcast found"),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList.builder(
                itemCount: podcastProvider.podcast!.episodes.length,
                itemBuilder: (context, index) {
                  return PoddrListItem(
                    leading: CurrentlyPlayingIcon(
                      episodeSource:
                          podcastProvider.podcast!.episodes[index].title,
                    ),
                    title: podcastProvider.podcast!.episodes[index].title,
                    subtitle: convertDateToString(podcastProvider
                        .podcast!.episodes[index].publicationDate),
                    actions: [
                      Text(
                        convertDurationToString(
                            podcastProvider.podcast!.episodes[index].duration ??
                                Duration.zero),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert_rounded),
                      ),
                    ],
                    onTap: () {
                      context.read<MediaProvider>().loadMedia(
                            MediaItem(
                              id: podcastProvider
                                      .podcast!.episodes[index].contentUrl ??
                                  '',
                              album: podcastProvider.podcast!.title,
                              title: podcastProvider
                                  .podcast!.episodes[index].title,
                              artist: podcastProvider.podcast!.title,
                              artUri: Uri.parse(
                                podcastProvider
                                        .podcast!.episodes[index].imageUrl ??
                                    podcastProvider.podcast!.image ??
                                    '',
                              ),
                            ),
                          );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
