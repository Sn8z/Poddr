import 'package:flutter/material.dart';
import 'package:poddr/ui/components/audio/artwork.dart';
import 'package:poddr/ui/components/audio/duration_text.dart';
import 'package:poddr/ui/components/audio/episode_title.dart';
import 'package:poddr/ui/components/audio/media_title.dart';
import 'package:poddr/ui/components/audio/play_button.dart';
import 'package:poddr/ui/components/audio/position_text.dart';
import 'package:poddr/ui/components/audio/progress_slider.dart';
import 'package:poddr/ui/utils/gaps.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Now playing"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Artwork(),
            ),
          ),
          const MediaProgressSlider(),
          gapH8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PositionText(),
              DurationText(),
            ],
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
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.skip_previous_rounded),
                      ),
                      const PlayButton(
                        size: 72,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.skip_next_rounded),
                      ),
                    ],
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
