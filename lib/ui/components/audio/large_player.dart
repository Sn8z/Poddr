import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:poddr/ui/components/audio/duration_text.dart';
import 'package:poddr/ui/components/audio/episode_title.dart';
import 'package:poddr/ui/components/audio/media_title.dart';
import 'package:poddr/ui/components/audio/play_button.dart';
import 'package:poddr/ui/components/audio/position_text.dart';
import 'package:poddr/ui/components/audio/prev_button.dart';
import 'package:poddr/ui/components/audio/progress_slider.dart';
import 'package:poddr/ui/components/audio/queue_button.dart';
import 'package:poddr/ui/components/audio/repeat_button.dart';
import 'package:poddr/ui/components/audio/shuffle_button.dart';
import 'package:poddr/ui/components/audio/skip_button.dart';
import 'package:poddr/ui/components/audio/speed_button.dart';
import 'package:poddr/ui/components/audio/volume.dart';
import 'package:poddr/ui/components/navigation/fullscreen_button.dart';
import 'package:poddr/ui/utils/gaps.dart';

class LargePlayer extends StatelessWidget {
  const LargePlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHigh
                  .withValues(alpha: 0.75),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            clipBehavior: Clip.antiAlias,
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
                              EpisodeTitle(),
                              MediaTitle(),
                            ],
                          ),
                        ),
                      ),
                      ShuffleButton(),
                      const PreviousButton(
                        size: 36,
                      ),
                      gapW8,
                      const PlayButton(
                        size: 56,
                      ),
                      gapW8,
                      const SkipButton(
                        size: 36,
                      ),
                      RepeatButton(),
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
                                    const QueueButton(),
                                    const SpeedButton(),
                                    const FullscreenButton(),
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
          ),
        ),
      ),
    );
  }
}
