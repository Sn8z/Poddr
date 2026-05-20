import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/utils/gaps.dart';

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final Color highlightColor;
  final double radius;

  _ShimmerPainter({
    required this.progress,
    required this.baseColor,
    required this.highlightColor,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final gradient = LinearGradient(
      transform: const GradientRotation(0.5),
      stops: [
        (progress - 0.1).clamp(0.0, 1.0),
        progress.clamp(0.0, 1.0),
        (progress + 0.1).clamp(0.0, 1.0),
      ],
      colors: [baseColor, highlightColor, baseColor],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class ShimmerBox extends StatefulWidget {
  final double? height;
  final double? width;
  final double? radius;

  const ShimmerBox({
    super.key,
    this.height,
    this.width,
    this.radius,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final baseColor = theme.surfaceContainer;
    final highlightColor = theme.surfaceContainerHigh;
    final radius = widget.radius ?? 16.0;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ShimmerPainter(
              progress: _controller.value,
              baseColor: baseColor,
              highlightColor: highlightColor,
              radius: radius,
            ),
            child: const SizedBox(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ShimmerLoadingList extends StatelessWidget {
  final int itemCount;
  final double height;
  final double radius;

  const ShimmerLoadingList({
    super.key,
    this.itemCount = 5,
    this.height = 100,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(4, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i < 3 ? 20 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(height: 26, width: 100.0 + (i * 20), radius: 4),
              gapH8,
              ShimmerBox(height: 18, width: double.infinity, radius: 4),
              gapH4,
              ShimmerBox(height: 18, width: double.infinity, radius: 4),
              gapH4,
              ShimmerBox(height: 18, width: 200.0, radius: 4),
            ],
          ),
        );
      }),
    );
  }
}
