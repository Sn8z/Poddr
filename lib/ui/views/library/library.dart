import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/box.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/components/widgets/empty_state.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/layouts/page_layout.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/utils/gaps.dart';
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

        return PageLayout(
          header: PoddrAppBar(
            title: const Text('Library'),
            bottom: PoddrAppBarOptions(
              actions: [
                PoddrOutlinedButton(
                  child: const Text("Latest Episodes"),
                  onPressed: () => context.push("/library/latest"),
                ),
                gapW8,
                PoddrOutlinedButton(
                  child: const Text("Downloads"),
                  onPressed: () => context.push("/library/downloads"),
                ),
              ],
            ),
          ),
          child: viewModel.isLoading
              ? const ShimmerLoadingList()
              : viewModel.subscriptions.isEmpty
                  ? const EmptyState(
                      icon: LucideIcons.podcast,
                      title: 'No subscriptions yet',
                      subtitle: 'Subscribe to podcasts to see them here',
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          gapH16,
                          PoddrBox(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: viewModel.subscriptions.length,
                              itemBuilder: (context, index) {
                                final Podcast podcast =
                                    viewModel.subscriptions[index];
                                return PoddrListItem(
                                  title: podcast.title ?? 'Missing Title',
                                  subtitle: podcast.author ?? 'Missing Author',
                                  onTap: () {
                                    final rss =
                                        Uri.encodeComponent(podcast.rss ?? '');
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
                                      icon:
                                          const Icon(LucideIcons.moreVertical),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const BottomPaddingFix(),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}
