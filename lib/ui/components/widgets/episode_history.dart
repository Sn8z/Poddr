import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/data/db/drift/database.dart';
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
      child: StreamBuilder<ListeningHistoryData?>(
        stream: context.read<HistoryProvider>().watchProgressByAudioUrl(audioUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          } else if (snapshot.hasError) {
            return const SizedBox();
          } else if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            if (data.isFinished) {
              return PoddrLinearProgress(
                value: 1.0,
                height: height,
              );
            } else {
              final value = data.position / data.duration;
              final finiteValue = value >= 0 && value <= 1 ? value.toDouble() : 0.0;
              return PoddrLinearProgress(
                value: finiteValue,
                height: height,
              );
            }
          } else {
            return const SizedBox();
          }
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
      child: StreamBuilder<ListeningHistoryData?>(
        stream: context.read<HistoryProvider>().watchProgressByAudioUrl(audioUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          } else if (snapshot.hasError) {
            return const SizedBox();
          } else if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            if (data.isFinished) {
              return _CircularProgress(
                value: 1.0,
                strokeWidth: size! / 5,
              );
            } else {
              final value = data.position / data.duration;
              final finiteValue = value >= 0 && value <= 1 ? value.toDouble() : 0.0;
              return _CircularProgress(
                value: finiteValue,
                strokeWidth: size! / 5,
              );
            }
          } else {
            return const SizedBox();
          }
        },
      ),
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
