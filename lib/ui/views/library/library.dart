import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/services/subscriptions.dart';
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
              SliverList.builder(
                itemCount: subscriptionProvider.subscriptions.length,
                itemBuilder: (context, index) {
                  return PoddrListItem(
                    title: subscriptionProvider.subscriptions[index].title ??
                        'Missing Title',
                    subtitle:
                        subscriptionProvider.subscriptions[index].author ??
                            'Missing Author',
                    onTap: () {
                      context.push(
                          '/podcasts/details?rss=${subscriptionProvider.subscriptions[index].rss}');
                    },
                    leading: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: PoddrImage(
                        imageUrl:
                            subscriptionProvider.subscriptions[index].image ??
                                '',
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
            ],
            const BottomPaddingFix(),
          ],
        ),
      ),
    );
  }
}
