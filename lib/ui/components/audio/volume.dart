import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:flutter/gestures.dart';
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
        Icon(
          _getVolumeIcon(volume),
          color: context.theme.onSurface,
          size: size,
        ),
        _VolumeControl(
          mediaProvider: mediaProvider,
          volume: volume,
        ),
      ],
    );
  }

  IconData _getVolumeIcon(double volume) {
    if (volume == 0) return LucideIcons.micOff;
    if (volume <= 50) return LucideIcons.music;
    return LucideIcons.music;
  }
}

class _VolumeControl extends StatelessWidget {
  final MediaProvider mediaProvider;
  final double volume;

  const _VolumeControl({
    required this.mediaProvider,
    required this.volume,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
          onChanged: mediaProvider.setVolume,
        ),
      ),
    );
  }
}
