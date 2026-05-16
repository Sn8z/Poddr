import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrSpinner extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const PoddrSpinner({
    super.key,
    this.size = 36,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  State<PoddrSpinner> createState() => _PoddrSpinnerState();
}

class _PoddrSpinnerState extends State<PoddrSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.14159,
            child: CustomPaint(
              painter: _SpinnerPainter(
                color: widget.color ?? context.theme.primary,
                strokeWidth: widget.strokeWidth,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _SpinnerPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    canvas.drawArc(rect, -0.5, 2.5, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) => false;
}

class PoddrLinearProgress extends StatelessWidget {
  final double value;
  final double height;
  final Color? color;
  final Color? backgroundColor;

  const PoddrLinearProgress({
    super.key,
    this.value = 1.0,
    this.height = 4,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _LinearProgressPainter(
        value: value,
        color: color ?? theme.primary,
        backgroundColor: backgroundColor ?? theme.surfaceContainerHighest,
        height: height,
      ),
    );
  }
}

class _LinearProgressPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double height;

  _LinearProgressPainter({
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, height),
      Radius.circular(height / 2),
    );

    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRRect(rect, bgPaint);

    final progressWidth = size.width * value;
    final progressRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, progressWidth, height),
      Radius.circular(height / 2),
    );

    final progressPaint = Paint()..color = color;
    canvas.drawRRect(progressRect, progressPaint);
  }

  @override
  bool shouldRepaint(_LinearProgressPainter oldDelegate) =>
      oldDelegate.value != value;
}
