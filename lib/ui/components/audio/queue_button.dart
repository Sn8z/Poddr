import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/poddr_list.dart';
import 'package:provider/provider.dart';

class QueueButton extends StatelessWidget {
  final double size;

  const QueueButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    return PoddrIconButton(
      icon: const Icon(LucideIcons.music),
      onPressed: () {
        showPoddrDialog(
          context: context,
          builder: (context) {
            return PoddrDialog(
              child: Selector<MediaProvider, List<PodcastEpisode>>(
                selector: (_, mediaProvider) => mediaProvider.mediaQueue,
                builder: (context, queue, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Queue (${queue.length})',
                        style: context.theme.textTheme.titleMedium,
                      ),
                      if (queue.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Your queue is empty.',
                            style: context.theme.textTheme.bodyMedium.copyWith(
                              color: context.theme.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.maxFinite,
                          height: 300,
                          child: ListView.separated(
                            itemCount: queue.length,
                            separatorBuilder: (context, index) =>
                                const PoddrDivider(height: 1),
                            itemBuilder: (context, index) {
                              final episode = queue[index];
                              return PoddrListTile(
                                title: episode.title ?? '',
                                subtitle: episode.podcastTitle ?? '',
                                trailing: PoddrIconButton(
                                  icon: const Icon(LucideIcons.x),
                                  size: 20,
                                  color: context.theme.onSurfaceVariant,
                                  onPressed: () {
                                    context
                                        .read<MediaProvider>()
                                        .removeQueueItem(index);
                                  },
                                ),
                                onTap: () {
                                  context
                                      .read<MediaProvider>()
                                      .skipToQueueItem(index);
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
