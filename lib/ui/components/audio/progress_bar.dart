import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/ui/components/widgets/poddr_progress.dart';

class MediaProgressBar extends StatelessWidget {
  const MediaProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    Duration duration =
        context.select<MediaProvider, Duration>((e) => e.duration);
    Duration position =
        context.select<MediaProvider, Duration>((e) => e.position);

    return PoddrLinearProgress(
      value: _calcProgress(position, duration),
      height: 4,
    );
  }

  double _calcProgress(Duration position, Duration duration) {
    double currentValue = position.inSeconds.toDouble();
    double maxValue = duration.inSeconds.toDouble();

    currentValue = currentValue.clamp(0, maxValue);

    double progress = position.inSeconds / duration.inSeconds;
    progress = progress.isFinite ? progress : 0;

    return progress;
  }
}
