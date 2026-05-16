import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/sliver_box.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/components/widgets/poddr_progress.dart';
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
              PoddrElevatedButton(
                child: const Text("Latest Episodes"),
                onPressed: () => context.push("/library/latest"),
              ),
              PoddrElevatedButton(
                child: const Text("Downloads"),
                onPressed: () => context.push("/library/downloads"),
              ),
            ],
          ),
          optionsActions: [
            PoddrIconButton(
              icon: const Icon(LucideIcons.plus),
              onPressed: () {
                showPoddrDialog(
                    context: context,
                    builder: (dialogContext) {
                      return PoddrDialog(
                        child: Padding(
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
                      );
                    });
              },
            )
          ],
          children: [
            if (viewModel.isLoading) ...[
              const SliverToBoxAdapter(
                child: Center(
                  child: PoddrSpinner(),
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
                        PoddrIconButton(
                          onPressed: () {},
                          icon: Icon(LucideIcons.moreVertical),
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
