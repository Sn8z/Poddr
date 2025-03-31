import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/sliver_box.dart';
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
            const PoddrAppBar(
              title: 'Library',
            ),
            PoddrAppBarOptions(
              title: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.view_module_rounded),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.view_headline_rounded),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                )
              ],
            ),
            sliverGapH8,
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
              PoddrSliverBox(
                sliver: SliverList.builder(
                  itemCount: subscriptionProvider.subscriptions.length,
                  itemBuilder: (context, index) {
                    final Podcast podcast =
                        subscriptionProvider.subscriptions[index];
                    return PoddrListItem(
                      title: podcast.title ?? 'Missing Title',
                      subtitle: podcast.author ?? 'Missing Author',
                      onTap: () {
                        final rss = Uri.encodeComponent(podcast.rss ?? '');
                        context.push('/podcasts/$rss');
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
                ),
              ),
            ],
            const BottomPaddingFix(),
          ],
        ),
      ),
    );
  }
}
