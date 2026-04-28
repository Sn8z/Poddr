import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/components/widgets/dialog.dart';
import 'package:poddr/ui/components/widgets/download_button.dart';
import 'package:poddr/ui/components/widgets/episode_history.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/utils/gaps.dart';
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
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomScrollView(
              slivers: [
                PoddrAppBar(
                  title: 'Latest Episodes',
                ),
                PoddrAppBarOptions(
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return PoddrTextInput(
                          labelText: "Filter",
                          hintText: "Type to filter episodes...",
                          onChanged: (value) {
                            viewModel.setFilter(value);
                          },
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              viewModel.setFilter('');
                            },
                          ),
                        );
                      } else {
                        return IconButton(
                          icon: const Icon(Icons.search_rounded),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return PoddrDialog(
                                  children: [
                                    PoddrTextInput(
                                      labelText: "Filter",
                                      hintText: "Type to filter episodes...",
                                      onSubmit: (value) {
                                        viewModel.setFilter(value);
                                        context.pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                  actions: [
                    ElevatedButton(
                      child: Text(viewModel.sortField),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return PoddrDialog(
                              children: [
                                for (var field in EpisodeSortField.values)
                                  ListTile(
                                    title: Text(field.label),
                                    onTap: () {
                                      viewModel.setSort(field: field);
                                      context.pop();
                                    },
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: viewModel.sortDirection == "Ascending"
                          ? const Icon(Icons.arrow_upward_rounded)
                          : const Icon(Icons.arrow_downward_rounded),
                      onPressed: () {
                        viewModel.setSort(
                          direction: viewModel.sortDirection == "Ascending"
                              ? SortDirection.descending
                              : SortDirection.ascending,
                        );
                      },
                    ),
                  ],
                ),
                sliverGapH16,
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
                const BottomPaddingFix(),
              ],
            ),
          ),
        );
      },
    );
  }
}
