import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final double height;

  const PoddrSlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 1,
    this.divisions,
    required this.onChanged,
    this.height = 4,
  });

  @override
  State<PoddrSlider> createState() => _PoddrSliderState();
}

class _PoddrSliderState extends State<PoddrSlider> {
  bool _dragging = false;

  void _onPanUpdate(DragUpdateDetails details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(details.globalPosition);
    final fraction = (localPos.dx / box.size.width).clamp(0.0, 1.0);
    double value = widget.min + fraction * (widget.max - widget.min);

    if (widget.divisions != null) {
      value = (value * widget.divisions!).round() / widget.divisions!;
    }

    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final fraction = (widget.value - widget.min) / (widget.max - widget.min);

    return GestureDetector(
      onPanDown: (_) => setState(() => _dragging = true),
      onPanUpdate: (details) => _onPanUpdate(details, context),
      onPanEnd: (_) => setState(() => _dragging = false),
      child: SizedBox(
        height: 24,
        child: CustomPaint(
          size: const Size(double.infinity, 24),
          painter: _SliderPainter(
            fraction: fraction,
            trackHeight: widget.height,
            activeColor: theme.primary,
            inactiveColor: theme.onSurfaceVariant.withAlpha(50),
            thumbColor: theme.primary,
            showThumb: _dragging,
          ),
        ),
      ),
    );
  }
}

class _SliderPainter extends CustomPainter {
  final double fraction;
  final double trackHeight;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbColor;
  final bool showThumb;

  _SliderPainter({
    required this.fraction,
    required this.trackHeight,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbColor,
    required this.showThumb,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final trackRadius = trackHeight / 2;

    final inactiveRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, centerY - trackRadius, size.width, trackHeight),
      Radius.circular(trackRadius),
    );

    final inactivePaint = Paint()..color = inactiveColor;
    canvas.drawRRect(inactiveRect, inactivePaint);

    final activeWidth = size.width * fraction;
    final activeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, centerY - trackRadius, activeWidth, trackHeight),
      Radius.circular(trackRadius),
    );

    final activePaint = Paint()..color = activeColor;
    canvas.drawRRect(activeRect, activePaint);

    if (showThumb) {
      final thumbX = activeWidth;
      final thumbRadius = trackHeight * 1.5;
      final thumbPaint = Paint()..color = thumbColor;
      canvas.drawCircle(Offset(thumbX, centerY), thumbRadius, thumbPaint);
    }
  }

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.showThumb != showThumb;
}
