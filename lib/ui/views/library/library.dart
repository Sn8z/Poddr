import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/sliver_box.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/layouts/scrolling_page.dart';
import 'package:poddr/ui/views/library/library_view_model.dart';
import 'package:provider/provider.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<SubscriptionProvider, LibraryViewModel>(
      create: (context) => LibraryViewModel(
        context.read<SubscriptionProvider>(),
      ),
      update: (_, subscription, previous) =>
          previous ?? LibraryViewModel(subscription),
      builder: (context, child) {
        final viewModel = context.watch<LibraryViewModel>();

        return ScrollingPageLayout(
          title: 'Library',
          optionsTitle: Row(
            children: [
              ElevatedButton(
                child: Text("Latest Episodes"),
                onPressed: () => context.push("/library/latest"),
              ),
              ElevatedButton(
                child: Text("Downloads"),
                onPressed: () => context.push("/library/downloads"),
              ),
            ],
          ),
          optionsActions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return SimpleDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(16),
                          ),
                        ),
                        backgroundColor: Theme.of(dialogContext)
                            .colorScheme
                            .surfaceContainerLow,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PoddrTextInput(
                              hintText: "Input RSS",
                              onSubmit: (value) {
                                context
                                    .read<LibraryViewModel>()
                                    .addSubscription(rss: value);
                                context.pop();
                              },
                            ),
                          ),
                        ],
                      );
                    });
              },
            )
          ],
          children: [
            if (viewModel.isLoading) ...[
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
            ] else if (viewModel.subscriptions.isEmpty) ...[
              const SliverToBoxAdapter(
                child: Center(
                  child: Text('Your library is empty'),
                ),
              ),
            ] else ...[
              PoddrSliverBox(
                sliver: SliverList.builder(
                  itemCount: viewModel.subscriptions.length,
                  itemBuilder: (context, index) {
                    final Podcast podcast =
                        viewModel.subscriptions[index];
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
          ],
        );
      },
    );
  }
}
