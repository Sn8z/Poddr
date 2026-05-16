import 'package:flutter/material.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/ui/components/widgets/dialog.dart';
import 'package:provider/provider.dart';

class QueueButton extends StatelessWidget {
  final double size;

  const QueueButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.queue_music_rounded,
        color: context.theme.onSurface,
        size: size,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return PoddrDialog(
              children: [
                Selector<MediaProvider, List<PodcastEpisode>>(
                  selector: (_, mediaProvider) => mediaProvider.mediaQueue,
                  builder: (context, queue, child) {
                    return Column(
                      children: [
                        Text(
                          'Queue (${queue.length})',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                context.theme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (queue.isEmpty)
                          Text(
                            'Your queue is empty.',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.theme.onSurfaceVariant,
                            ),
                          )
                        else
                          SizedBox(
                            width: double.maxFinite,
                            height: 300,
                            child: ListView.separated(
                              itemCount: queue.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final episode = queue[index];
                                return ListTile(
                                  title: Text(
                                    episode.title ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.theme.onSurfaceVariant,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(
                                    episode.podcastTitle ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.theme.onSurfaceVariant,
                                    ),
                                  ),
                                  onTap: () {
                                    context
                                        .read<MediaProvider>()
                                        .skipToQueueItem(index);
                                    Navigator.of(context).pop();
                                  },
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.close_rounded,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<MediaProvider>()
                                          .removeQueueItem(index);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
