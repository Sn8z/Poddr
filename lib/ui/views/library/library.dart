import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:provider/provider.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();

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
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              toolbarHeight: 82,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHigh,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              surfaceTintColor: Theme.of(context).colorScheme.primary,
              title: Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.mic)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.motion_photos_paused_sharp)),
                ],
              ),
            ),
            sliverGapH16,
            if (subscriptionProvider.isLoading) ...[
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
            ] else if (subscriptionProvider.subscriptions.isEmpty) ...[
              const SliverToBoxAdapter(
                child: Text('Your library is empty'),
              ),
            ] else ...[
              ContentBox(
                title: "Library",
                subtitle: "Your library",
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                  ),
                ],
                children: [
                  ...subscriptionProvider.subscriptions.map(
                    (Podcast podcast) {
                      return PoddrListItem(
                        title: podcast.title ?? 'Missing Title',
                        subtitle: podcast.author ?? 'Missing Author',
                        onTap: () {
                          context.push('/podcasts/details?rss=${podcast.rss}');
                        },
                        leading: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PoddrImage(
                            imageUrl: podcast.image ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_vert_rounded),
                          ),
                        ],
                      );
                    },
                  )
                ],
              ),
            ],
            const BottomPaddingFix(),
          ],
        ),
      ),
    );
  }
}
