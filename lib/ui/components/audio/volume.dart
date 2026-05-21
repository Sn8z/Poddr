import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/ui/components/widgets/poddr_slider.dart';

class VolumeSlider extends StatelessWidget {
  final double size;

  const VolumeSlider({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final mediaProvider = context.read<MediaProvider>();
    final volume = context.select<MediaProvider, double>((e) => e.volume);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PoddrIconButton(
          icon: switch (volume.round()) {
            <= 0 => FaIcon(FontAwesomeIcons.volumeXmark, color: context.theme.error),
            <= 33 => FaIcon(FontAwesomeIcons.volumeHigh, color: context.theme.secondary),
            <= 66 => FaIcon(FontAwesomeIcons.volumeLow, color: context.theme.secondary),
            _ => FaIcon(FontAwesomeIcons.volumeHigh, color: context.theme.secondary),
          },
          onPressed: () {
            mediaProvider.toggleMute();
          },
        ),
        SizedBox(
          width: 160,
          child: Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                if (event.scrollDelta.dy < 0) {
                  mediaProvider.increaseVolume();
                } else {
                  mediaProvider.decreaseVolume();
                }
              }
            },
            child: PoddrSlider(
              value: volume,
              min: 0.0,
              max: 100.0,
              thumbVisibility: PoddrThumbVisibility.onInteraction,
              trackHeight: 6,
              onChanged: mediaProvider.setVolume,
            ),
          ),
        ),
      ],
    );
  }
}
