import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
            <= 0 => Icon(LucideIcons.volumeX, color: context.theme.error),
            <= 33 => Icon(LucideIcons.volume, color: context.theme.secondary),
            <= 66 => Icon(LucideIcons.volume1, color: context.theme.secondary),
            _ => Icon(LucideIcons.volume2, color: context.theme.secondary),
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
