import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:poddr/ui/components/audio/currently_playing.dart';
import 'package:poddr/ui/components/widgets/add_fav_btn.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/components/widgets/tag.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/services/media.dart';
import 'package:poddr/services/podcast.dart';
import 'package:poddr/ui/utils/gaps.dart';
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainerLow
                  : Theme.of(context).colorScheme.primaryContainer,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
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
                                  Row(
                                    children: podcastProvider.podcast?.tags
                                            .map((e) => PoddrTag(
                                                  title: e,
                                                  color: Colors.grey,
                                                ))
                                            .toList() ??
                                        [],
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
                  ],
                ),
              ),
              expandedHeight: 320,
              actions: [
                PoddrAddFavBtn(
                  title: podcastProvider.podcast?.title ?? "",
                  rss: podcastProvider.podcast?.rss ?? "",
                  description: podcastProvider.podcast?.description ?? "",
                  author: podcastProvider.podcast?.title ?? "",
                  image: podcastProvider.podcast?.image ?? "",
                ),
              ],
            ),
            const SliverToBoxAdapter(
              child: gapH12,
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
                      subtitle: podcastProvider
                              .podcast!.episodes[index].publicationDate ??
                          "date",
                      actions: [
                        const Text("00:00"),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert_rounded),
                        ),
                      ],
                      onTap: () {
                        context.read<MediaProvider>().loadMedia(
                              MediaItem(
                                id: podcastProvider
                                    .podcast!.episodes[index].audioUrl,
                                album: podcastProvider.podcast!.title,
                                title: podcastProvider
                                    .podcast!.episodes[index].title,
                                artist: podcastProvider.podcast!.title,
                                artUri: Uri.parse(
                                  podcastProvider
                                          .podcast!.episodes[index].imageUrl ??
                                      podcastProvider.podcast!.image ??
                                      "",
                                ),
                              ),
                            );
                      },
                    );
                  },
                ),
              ),
            const BottomPaddingFix(),
          ],
        ),
      ),
    );
  }
}
