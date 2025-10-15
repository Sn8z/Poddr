import 'package:flutter/material.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/services/media.dart';
import 'package:poddr/ui/components/widgets/dialog.dart';
import 'package:provider/provider.dart';

class QueueButton extends StatelessWidget {
  final double size;

  const QueueButton({
    super.key,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    List<PodcastEpisode> queue = context.watch<MediaProvider>().mediaQueue;

    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return PoddrDialog(
              children: [
                Text(
                  'Queue (${queue.length})',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (queue.isEmpty)
                  Text(
                    'Your queue is empty.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                            episode.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            episode.podcastTitle ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
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
              // children: [
              //   const Text('Queue'),
              //   SimpleDialogOption(
              //     onPressed: () {},
              //     child: const Text('1'),
              //   ),
              //   SimpleDialogOption(
              //     onPressed: () {},
              //     child: const Text('2'),
              //   ),
              //   SimpleDialogOption(
              //     onPressed: () {},
              //     child: const Text('3'),
              //   ),
              //   SimpleDialogOption(
              //     onPressed: () {},
              //     child: const Text('4'),
              //   ),
              // ],
            );
          },
        );
      },
      icon: Icon(
        Icons.queue_music_rounded,
        size: size,
      ),
    );
  }
}
