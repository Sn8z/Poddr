import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/collection.dart';
import 'package:poddr/ui/components/widgets/add_subscription_btn.dart';
import 'package:poddr/ui/components/widgets/collections_display.dart';
import 'package:poddr/ui/components/widgets/collection_link_button.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/download_button.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/html.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/components/widgets/sliver_box.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/ui/views/podcast/podcast_view_model.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/utils/string_converter.dart';
import 'package:provider/provider.dart';

class PodcastDetailsView extends StatelessWidget {
  const PodcastDetailsView({super.key, required this.rss});
  final String rss;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PodcastViewModel(initialRss: rss),
      builder: (context, child) {
        final podcastProvider = context.watch<PodcastViewModel>();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _PodcastAppBarDelegate(
                  podcastProvider: podcastProvider,
                ),
              ),
              PoddrAppBarOptions(
                title: Row(
                  children: [
                    PoddrIconButton(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.list),
                    ),
                    PoddrIconButton(
                      icon: const Icon(LucideIcons.search),
                      onPressed: () {
                        showPoddrDialog(
                          context: context,
                          builder: (dialogContext) {
                            return PoddrDialog(
                              child: PoddrTextInput(
                                labelText: "Filter",
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                actions: [
                  PoddrAddSubscriptionBtn(rss: rss),
                  PoddrIconButton(
                    icon: const Icon(LucideIcons.info),
                    onPressed: () {
                      showPoddrDialog(
                        context: context,
                        builder: (dialogContext) {
                          return PoddrDialog(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  podcastProvider.podcast?.title ?? "Podcast",
                                  style: context.theme.textTheme.headlineSmall,
                                ),
                                PoddrHTML(
                                    html:
                                        podcastProvider.podcast?.description ??
                                            ""),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: StreamBuilder<int?>(
                  stream: context
                      .read<SubscriptionProvider>()
                      .watchSubscriptionId(rss),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    final subscriptionId = snapshot.data;
                    if (subscriptionId == null) {
                      return const SizedBox.shrink();
                    }
                    return StreamBuilder<List<PodcastCollection>>(
                      stream: context
                          .read<CollectionsProvider>()
                          .watchCollectionsForSubscription(subscriptionId),
                      builder: (context, colSnapshot) {
                        final collections = colSnapshot.data ?? [];
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: PoddrCollectionsDisplay(collections: collections),
                              ),
                              gapW8,
                              PoddrCollectionLinkButton(subscriptionId: subscriptionId),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              sliverGapH8,
              if (podcastProvider.isLoading)
                SliverList.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return const PoddrListItem(
                      data: ShimmerBox(
                        height: 48,
                        radius: 16,
                      ),
                    );
                  },
                )
              else if (podcastProvider.podcast == null)
                const SliverFillRemaining(
                  child: Text("No podcast found"),
                )
              else
                PoddrSliverBox(
                  sliver: SliverList.builder(
                    itemCount: podcastProvider.podcast!.episodes.length,
                    itemBuilder: (context, index) {
                      return Episode(
                          episode: podcastProvider.podcast!.episodes[index]);
                    },
                  ),
                ),
              const BottomPaddingFix(),
            ],
          ),
        );
      },
    );
  }
}

class _PodcastAppBarDelegate extends SliverPersistentHeaderDelegate {
  final PodcastViewModel podcastProvider;

  _PodcastAppBarDelegate({required this.podcastProvider});

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    final isMobile = MediaQuery.sizeOf(context).width < Breakpoints.mobileScreen;
    final theme = context.theme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.surfaceContainerLow
            : theme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.surfaceContainer,
                        theme.surfaceContainerLow,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: isMobile
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: podcastProvider.isLoading
                                ? const ShimmerBox()
                                : PoddrImage(
                                    imageUrl: podcastProvider.podcast?.image ??
                                        "",
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          gapH8,
                          Text(
                            podcastProvider.podcast?.title ?? "",
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.primary,
                            ),
                          ),
                          gapH8,
                          Text(
                            podcastProvider.podcast?.author ?? "",
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 200,
                            width: 200,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: PoddrImage(
                              imageUrl: podcastProvider.podcast?.image ?? "",
                              fit: BoxFit.cover,
                            ),
                          ),
                          gapW16,
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  podcastProvider.podcast?.title ?? "",
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primary,
                                  ),
                                ),
                                gapH8,
                                Text(
                                  podcastProvider.podcast?.author ?? "",
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: theme.onSurfaceVariant,
                                  ),
                                ),
                                gapH8,
                                Text(
                                  "${podcastProvider.podcast?.episodes.length ?? 0} Episodes",
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  double get maxExtent => 280;

  @override
  double get minExtent => 120;

  @override
  bool shouldRebuild(_PodcastAppBarDelegate oldDelegate) =>
      oldDelegate.podcastProvider != podcastProvider;
}

class Episode extends StatelessWidget {
  final PodcastEpisode episode;

  const Episode({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    final podcastProvider = context.read<PodcastViewModel>();

    final isCurrentEpisode =
        context.select<MediaProvider, bool>((mediaProvider) {
      return mediaProvider.episodeTitle == episode.title;
    });

    return PoddrListItem(
      title: episode.title,
      subtitle: convertDateToString(episode.publicationDate),
      isActive: isCurrentEpisode,
      actions: [
        Text(
          convertDurationToString(
            episode.duration,
          ),
          maxLines: 1,
          style: TextStyle(
            color: isCurrentEpisode
                ? context.theme.onSurface
                : context.theme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PoddrIconButton(
          icon: const Icon(
            LucideIcons.info,
            size: 24,
          ),
          onPressed: () {
            showPoddrDialog(
              context: context,
              builder: (dialogContext) {
                return PoddrDialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode.title ?? '',
                        style: context.theme.textTheme.headlineSmall,
                      ),
                      gapH16,
                      PoddrHTML(html: episode.description ?? ''),
                    ],
                  ),
                );
              },
            );
          },
        ),
        PoddrIconButton(
          onPressed: () {
            context.read<MediaProvider>().addToQueue(
                  audioUrl: episode.audioUrl,
                  videoUrl: episode.videoUrl,
                  episodeTitle: episode.title,
                  podcastTitle: episode.podcastTitle,
                  podcastRSS: podcastProvider.podcast!.rss ?? "Missing RSS",
                  description: episode.description,
                  artUri: podcastProvider.podcast!.image,
                  album: episode.title,
                  artist: podcastProvider.podcast!.author,
                );
          },
          icon: const Icon(
            LucideIcons.listMusic,
            size: 24,
          ),
        ),
        EpisodeHistoryCircle(
          audioUrl: episode.audioUrl,
          size: 18,
        ),
        DownloadButton(episode: episode),
      ],
      onTap: () {
        context.read<MediaProvider>().loadMedia(
              audioUrl: episode.audioUrl,
              videoUrl: episode.videoUrl,
              episodeTitle: episode.title,
              podcastTitle: episode.podcastTitle,
              podcastRSS: podcastProvider.podcast!.rss ?? "Missing RSS",
              description: episode.description,
              artUri: podcastProvider.podcast!.image,
              album: episode.title,
              artist: podcastProvider.podcast!.author,
            );
      },
    );
  }
}
