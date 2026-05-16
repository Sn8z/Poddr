import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/ui/components/audio/media_display.dart';
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
import 'package:poddr/ui/components/audio/next_button.dart';
import 'package:poddr/ui/components/audio/speed_button.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PoddrIconButton(
                onPressed: () {},
                icon: Icon(LucideIcons.moreVertical),
              ),
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: MediaDisplay(),
          ),
        ),
        const MediaProgressSlider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PositionText(),
              DurationText(),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              gapH16,
              const EpisodeTitle(),
              gapH16,
              const MediaTitle(),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ShuffleButton(
                      size: 36,
                    ),
                    gapW16,
                    PreviousButton(
                      size: 36,
                    ),
                    gapW16,
                    const PlayButton(
                      size: 72,
                    ),
                    gapW16,
                    SkipButton(
                      size: 36,
                    ),
                    gapW16,
                    RepeatButton(
                      size: 36,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            QueueButton(
              size: 32,
            ),
            gapW16,
            SpeedButton(
              size: 32,
            ),
          ],
        ),
        gapH16,
      ],
    );
  }
}
