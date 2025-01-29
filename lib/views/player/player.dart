import 'package:flutter/material.dart';
import 'package:poddr/components/audio/artwork.dart';
import 'package:poddr/components/audio/episode_title.dart';
import 'package:poddr/components/audio/media_title.dart';
import 'package:poddr/components/audio/play_button.dart';
import 'package:poddr/components/audio/progress_slider.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Now playing"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Expanded(
            child: Artwork(),
          ),
          const MediaProgressSlider(),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 16),
                const EpisodeTitle(),
                const SizedBox(height: 16),
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
                      const PlayButton(),
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
