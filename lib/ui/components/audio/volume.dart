import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
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
          semanticLabel: volume == 0 ? 'Unmute' : 'Mute',
          icon: switch (volume.round()) {
            <= 0 => HugeIcon(
                icon: HugeIcons.strokeRoundedVolumeOff,
                color: context.theme.error,
              ),
            <= 33 => HugeIcon(
                icon: HugeIcons.strokeRoundedVolumeMute01,
                color: context.theme.secondary,
              ),
            <= 66 => HugeIcon(
                icon: HugeIcons.strokeRoundedVolumeLow,
                color: context.theme.secondary,
              ),
            _ => HugeIcon(
                icon: HugeIcons.strokeRoundedVolumeHigh,
                color: context.theme.secondary,
              ),
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
              semanticLabel: 'Volume',
              valueLabel: '${volume.round()}%',
              onChanged: mediaProvider.setVolume,
            ),
          ),
        ),
      ],
    );
  }
}
