import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/models/progress.dart';
import 'package:poddr/services/history.dart';
import 'package:poddr/ui/components/widgets/poddr_progress.dart';
import 'package:provider/provider.dart';

class EpisodeHistory extends StatelessWidget {
  final double height;
  final double? width;
  final String audioUrl;

  const EpisodeHistory({
    super.key,
    required this.audioUrl,
    this.height = 6,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: _ProgressStreamBuilder(
        audioUrl: audioUrl,
        builder: (context, progress) {
          if (progress == null) return const SizedBox();
          return PoddrLinearProgress(
            value: _progressValue(progress),
            height: height,
          );
        },
      ),
    );
  }
}

class EpisodeHistoryCircle extends StatelessWidget {
  final double? size;
  final String audioUrl;

  const EpisodeHistoryCircle({
    super.key,
    required this.audioUrl,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: _ProgressStreamBuilder(
        audioUrl: audioUrl,
        builder: (context, progress) {
          if (progress == null) return const SizedBox();
          return _CircularProgress(
            value: _progressValue(progress),
            strokeWidth: size! / 5,
          );
        },
      ),
    );
  }
}

double _progressValue(EpisodeProgress progress) {
  if (progress.isFinished) return 1.0;
  final value = progress.position / progress.duration;
  return value >= 0 && value <= 1 ? value : 0.0;
}

class _ProgressStreamBuilder extends StatefulWidget {
  final String audioUrl;
  final Widget Function(BuildContext context, EpisodeProgress? progress)
      builder;

  const _ProgressStreamBuilder({
    required this.audioUrl,
    required this.builder,
  });

  @override
  State<_ProgressStreamBuilder> createState() => _ProgressStreamBuilderState();
}

class _ProgressStreamBuilderState extends State<_ProgressStreamBuilder> {
  late Stream<EpisodeProgress?> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _watch();
  }

  @override
  void didUpdateWidget(covariant _ProgressStreamBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _stream = _watch();
    }
  }

  Stream<EpisodeProgress?> _watch() =>
      context.read<HistoryProvider>().watchProgressByAudioUrl(widget.audioUrl);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EpisodeProgress?>(
      stream: _stream,
      builder: (context, snapshot) => widget.builder(context, snapshot.data),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  final double value;
  final double strokeWidth;

  const _CircularProgress({
    required this.value,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CircleProgressPainter(
        value: value,
        strokeWidth: strokeWidth,
        color: context.theme.primary,
        backgroundColor: context.theme.surface,
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  _CircleProgressPainter({
    required this.value,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) =>
      oldDelegate.value != value;
}
