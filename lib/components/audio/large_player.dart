import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/components/audio/duration_text.dart';
import 'package:poddr/components/audio/episode_title.dart';
import 'package:poddr/components/audio/media_title.dart';
import 'package:poddr/components/audio/play_button.dart';
import 'package:poddr/components/audio/position_text.dart';
import 'package:poddr/components/audio/progress_slider.dart';
import 'package:poddr/components/audio/volume.dart';

class LargePlayer extends StatelessWidget {
  const LargePlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Column(
        children: [
          const MediaProgressSlider(),
          Expanded(
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PositionText(),
                        Spacer(),
                        MediaTitle(),
                        EpisodeTitle(),
                      ],
                    ),
                  ),
                ),
                //const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.shuffle_rounded,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.skip_previous_rounded,
                    size: 28,
                  ),
                ),
                const PlayButton(
                  size: 58,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.skip_next_rounded,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.repeat_rounded,
                    size: 28,
                  ),
                ),
                //const Spacer(),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const DurationText(),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        title: const Text('Queue'),
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        children: [
                                          const Text('Queue'),
                                          SimpleDialogOption(
                                            onPressed: () {},
                                            child: const Text('1'),
                                          ),
                                          SimpleDialogOption(
                                            onPressed: () {},
                                            child: const Text('2'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.queue_music_rounded,
                                  size: 20,
                                ),
                              ),
                              PopupMenuButton(
                                icon:
                                    const Icon(Icons.one_x_mobiledata_rounded),
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem(
                                      child: const Text('Settings'),
                                      onTap: () => debugPrint('1'),
                                    ),
                                    PopupMenuItem(
                                      child: const Text('Settings'),
                                      onTap: () => debugPrint('2'),
                                    ),
                                    PopupMenuItem(
                                      child: const Text('Settings'),
                                      onTap: () => debugPrint('3'),
                                    ),
                                  ];
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  context.push('/player');
                                },
                                icon: const Icon(
                                  Icons.fullscreen_rounded,
                                  size: 20,
                                ),
                              ),
                              const VolumeSlider(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
