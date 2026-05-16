import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/components/widgets/download_button.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/components/widgets/poddr_list.dart';
import 'package:poddr/ui/layouts/scrolling_page.dart';
import 'package:poddr/ui/utils/string_converter.dart';
import 'package:poddr/ui/views/library/latest/latest_view_model.dart';
import 'package:provider/provider.dart';

class LatestEpisodesView extends StatelessWidget {
  const LatestEpisodesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<SubscriptionProvider,
        LatestEpisodesViewModel>(
      create: (context) => LatestEpisodesViewModel(
        context.read<SubscriptionProvider>(),
      ),
      update: (context, source, previous) =>
          previous ?? LatestEpisodesViewModel(source),
      builder: (context, child) {
        final viewModel = context.watch<LatestEpisodesViewModel>();

        return ScrollingPageLayout(
          title: 'Latest Episodes',
          optionsTitle: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return PoddrTextInput(
                  labelText: "Filter",
                  hintText: "Type to filter episodes...",
                  onChanged: (value) {
                    viewModel.setFilter(value);
                  },
                  suffixIcon: PoddrIconButton(
                    icon: const Icon(LucideIcons.x),
                    size: 20,
                    onPressed: () {
                      viewModel.setFilter('');
                    },
                  ),
                );
              } else {
                return PoddrIconButton(
                  icon: const Icon(LucideIcons.search),
                  onPressed: () {
                    showPoddrDialog(
                      context: context,
                      builder: (dialogContext) {
                        return PoddrDialog(
                          child: PoddrTextInput(
                            labelText: "Filter",
                            hintText: "Type to filter episodes...",
                            onSubmit: (value) {
                              viewModel.setFilter(value);
                              context.pop();
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
          optionsActions: [
            PoddrElevatedButton(
              child: Text(viewModel.sortField),
              onPressed: () {
                showPoddrDialog(
                  context: context,
                  builder: (dialogContext) {
                    return PoddrDialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var field in EpisodeSortField.values)
                            PoddrListTile(title: field.label,
                              onTap: () {
                                viewModel.setSort(field: field);
                                context.pop();
                              },
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            PoddrIconButton(
              icon: viewModel.sortDirection == "Ascending"
                  ? const Icon(LucideIcons.arrowUp)
                  : const Icon(LucideIcons.arrowDown),
              onPressed: () {
                viewModel.setSort(
                  direction: viewModel.sortDirection == "Ascending"
                      ? SortDirection.descending
                      : SortDirection.ascending,
                );
              },
            ),
          ],
          children: [
            if (viewModel.episodes.isEmpty) ...[
              const SliverToBoxAdapter(
                child: Center(
                  child: Text("No episodes found."),
                ),
              ),
            ] else ...[
              ContentBox(
                children: [
                  for (var episode in viewModel.episodes)
                    PoddrListItem(
                      title: episode.title,
                      subtitle: episode.author,
                      leading: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          borderRadius:
                              BorderRadius.all(Radius.circular(12)),
                        ),
                        child: PoddrImage(imageUrl: episode.imageUrl ?? ''),
                      ),
                      onTap: () {
                        context.read<MediaProvider>().loadMedia(
                              album: episode.podcastTitle,
                              podcastTitle: episode.podcastTitle,
                              episodeTitle: episode.title,
                              artist: episode.author,
                              description: episode.description,
                              audioUrl: episode.audioUrl,
                              videoUrl: episode.videoUrl,
                              podcastRSS: episode.podcastRSS,
                              artUri: episode.imageUrl,
                            );
                      },
                      actions: [
                        Text(convertDurationToString(episode.duration)),
                        EpisodeHistoryCircle(audioUrl: episode.audioUrl),
                        DownloadButton(episode: episode),
                      ],
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
