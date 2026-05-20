import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/ui/components/widgets/poddr_slider.dart';

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

    return PoddrSlider(
      value: currentValue,
      bufferedValue: bufferedValue,
      min: 0,
      max: maxValue,
      trackHeight: 12,
      thumbVisibility: PoddrThumbVisibility.never,
      trackShape: PoddrTrackShape.rounded,
      onChanged: (double value) {
        context.read<MediaProvider>().seek(
              Duration(
                seconds: value.toInt(),
              ),
            );
      },
    );
  }
}
