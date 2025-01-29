import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:poddr/providers/media.dart';

class MediaProgressSlider extends StatelessWidget {
  const MediaProgressSlider({super.key});

  @override
  Widget build(BuildContext context) {
    Duration duration =
        context.select<MediaProvider, Duration>((e) => e.duration);
    Duration position =
        context.select<MediaProvider, Duration>((e) => e.position);
    Duration bufferedPosition =
        context.select<MediaProvider, Duration>((e) => e.bufferedPosition);

    double maxValue = duration.inSeconds.toDouble();
    double currentValue = position.inSeconds.toDouble();
    double bufferedValue = bufferedPosition.inSeconds.toDouble();

    currentValue = currentValue.clamp(0, maxValue);
    bufferedValue = bufferedValue.clamp(0, maxValue);

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbShape: SliderComponentShape.noThumb,
        overlayShape: SliderComponentShape.noOverlay,
        trackShape: const RectangularSliderTrackShape(),
        trackHeight: 12,
      ),
      child: Slider(
        allowedInteraction: SliderInteraction.tapAndSlide,
        min: 0,
        max: maxValue,
        value: currentValue,
        secondaryTrackValue: bufferedValue,
        onChangeStart: (_) {
          context.read<MediaProvider>().pause();
        },
        onChangeEnd: (_) {
          context.read<MediaProvider>().play();
        },
        onChanged: (double value) {
          context.read<MediaProvider>().seek(
                Duration(
                  seconds: value.toInt(),
                ),
              );
        },
      ),
    );
  }
}
