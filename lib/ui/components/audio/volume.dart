import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

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
          color: Theme.of(context).colorScheme.onSurface,
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
    if (volume == 0) return Icons.volume_off;
    if (volume <= 50) return Icons.volume_down;
    return Icons.volume_up;
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
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        inactiveTrackColor: Theme.of(context)
            .colorScheme
            .onSurfaceVariant
            .withAlpha(50),
      ),
      child: SizedBox(
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
          child: Slider(
            value: volume,
            min: 0.0,
            max: 100.0,
            onChanged: mediaProvider.setVolume,
          ),
        ),
      ),
    );
  }
}
