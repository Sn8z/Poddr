import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

enum PoddrTrackShape { rounded, flat }
enum PoddrThumbVisibility { always, onInteraction, never }

class PoddrSlider extends StatefulWidget {
  final double value;
  final double? bufferedValue;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final VoidCallback? onChangeStart;
  final VoidCallback? onChangeEnd;
  final double trackHeight;
  final double thumbRadius;
  final PoddrThumbVisibility thumbVisibility;
  final double borderRadius;
  final PoddrTrackShape trackShape;
  final Gradient? activeGradient;
  final Gradient? inactiveGradient;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? bufferedColor;
  final Color? thumbColor;
  final bool enabled;
  final String? semanticLabel;
  final String? valueLabel;
  final double keyboardStep;

  const PoddrSlider({
    super.key,
    required this.value,
    this.bufferedValue,
    this.min = 0,
    this.max = 1,
    this.divisions,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.trackHeight = 4,
    this.thumbRadius = 0,
    this.thumbVisibility = PoddrThumbVisibility.onInteraction,
    this.borderRadius = 0,
    this.trackShape = PoddrTrackShape.rounded,
    this.activeGradient,
    this.inactiveGradient,
    this.activeColor,
    this.inactiveColor,
    this.bufferedColor,
    this.thumbColor,
    this.enabled = true,
    this.semanticLabel,
    this.valueLabel,
    this.keyboardStep = 0,
  });

  @override
  State<PoddrSlider> createState() => _PoddrSliderState();
}

class _PoddrSliderState extends State<PoddrSlider> with SingleTickerProviderStateMixin {
  bool _dragging = false;
  bool _hovering = false;
  late AnimationController _thumbAnimation;
  final _focusNode = FocusNode();

  bool get _shouldShowThumb {
    switch (widget.thumbVisibility) {
      case PoddrThumbVisibility.always:
        return true;
      case PoddrThumbVisibility.onInteraction:
        return _hovering || _dragging;
      case PoddrThumbVisibility.never:
        return false;
    }
  }

  void _updateThumbAnimation() {
    if (_shouldShowThumb) {
      _thumbAnimation.forward();
    } else {
      _thumbAnimation.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _thumbAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: widget.thumbVisibility == PoddrThumbVisibility.always ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(PoddrSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.thumbVisibility != oldWidget.thumbVisibility) {
      _updateThumbAnimation();
    }
  }

  @override
  void dispose() {
    _thumbAnimation.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  double _getValueFromPosition(Offset localPos, double width) {
    final fraction = (localPos.dx / width).clamp(0.0, 1.0);
    double value = widget.min + fraction * (widget.max - widget.min);

    if (widget.divisions != null) {
      value = (value * widget.divisions!).round() / widget.divisions!;
    }

    return value;
  }

  void _handlePanDown(DragDownDetails details, BuildContext context) {
    if (!widget.enabled) return;
    setState(() => _dragging = true);
    _updateThumbAnimation();
    widget.onChangeStart?.call();
    _updateValueFromGlobalPosition(details.globalPosition, context);
  }

  void _handlePanUpdate(DragUpdateDetails details, BuildContext context) {
    if (!widget.enabled) return;
    _updateValueFromGlobalPosition(details.globalPosition, context);
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    setState(() => _dragging = false);
    _updateThumbAnimation();
    widget.onChangeEnd?.call();
  }

  void _handlePanCancel() {
    if (!widget.enabled) return;
    setState(() => _dragging = false);
    _updateThumbAnimation();
    widget.onChangeEnd?.call();
  }

  void _updateValueFromGlobalPosition(Offset globalPosition, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(globalPosition);
    final value = _getValueFromPosition(localPos, box.size.width);
    widget.onChanged(value);
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    final box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(details.globalPosition);
    final value = _getValueFromPosition(localPos, box.size.width);
    widget.onChanged(value);
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent || !widget.enabled) return;

    double step = widget.keyboardStep;
    if (step == 0) {
      step = (widget.max - widget.min) / 100;
    }

    double newValue = widget.value;
    bool handled = false;

    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      newValue = (widget.value + step).clamp(widget.min, widget.max);
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      newValue = (widget.value - step).clamp(widget.min, widget.max);
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      newValue = widget.min;
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      newValue = widget.max;
      handled = true;
    }

    if (handled) {
      if (widget.divisions != null) {
        newValue = (newValue * widget.divisions!).round() / widget.divisions!;
      }
      widget.onChanged(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final fraction = widget.max != widget.min
        ? ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0)
        : 0.0;
    final bufferedFraction = widget.bufferedValue != null && widget.max != widget.min
        ? ((widget.bufferedValue! - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0)
        : 0.0;

    final effectiveTrackHeight = widget.trackHeight;
    final effectiveThumbRadius = widget.thumbRadius > 0
        ? widget.thumbRadius
        : effectiveTrackHeight * 1.5;
    final effectiveBorderRadius = widget.borderRadius > 0
        ? widget.borderRadius
        : effectiveTrackHeight / 2;

    final effectiveActiveColor = widget.activeColor ?? theme.primary;
    final effectiveInactiveColor = widget.inactiveColor ?? theme.onSurfaceVariant.withAlpha(50);
    final effectiveBufferedColor = widget.bufferedColor ?? theme.onSurfaceVariant.withAlpha(100);
    final effectiveThumbColor = widget.thumbColor ?? theme.primary;

    final sliderContent = GestureDetector(
      onTapDown: _handleTapDown,
      onPanDown: (details) => _handlePanDown(details, context),
      onPanUpdate: (details) => _handlePanUpdate(details, context),
      onPanEnd: _handlePanEnd,
      onPanCancel: _handlePanCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _thumbAnimation,
        builder: (context, child) {
          return SizedBox(
            height: effectiveTrackHeight,
            width: double.infinity,
            child: CustomPaint(
              painter: _SliderPainter(
                fraction: fraction,
                bufferedFraction: bufferedFraction,
                trackHeight: effectiveTrackHeight,
                thumbRadius: effectiveThumbRadius,
                borderRadius: effectiveBorderRadius,
                trackShape: widget.trackShape,
                activeColor: effectiveActiveColor,
                activeGradient: widget.activeGradient,
                inactiveColor: effectiveInactiveColor,
                inactiveGradient: widget.inactiveGradient,
                bufferedColor: effectiveBufferedColor,
                thumbColor: effectiveThumbColor,
                thumbOpacity: _shouldShowThumb ? _thumbAnimation.value : 0.0,
                showThumb: _shouldShowThumb && _thumbAnimation.value > 0.01,
                hasBuffered: widget.bufferedValue != null,
              ),
            ),
          );
        },
      ),
    );

    return Semantics(
      label: widget.semanticLabel ?? 'Slider',
      value: widget.valueLabel ?? widget.value.toStringAsFixed(2),
      increasedValue: (widget.value + (widget.keyboardStep > 0 ? widget.keyboardStep : (widget.max - widget.min) / 100)).toStringAsFixed(2),
      decreasedValue: (widget.value - (widget.keyboardStep > 0 ? widget.keyboardStep : (widget.max - widget.min) / 100)).toStringAsFixed(2),
      child: MouseRegion(
        cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) {
          setState(() => _hovering = true);
          _updateThumbAnimation();
        },
        onExit: (_) {
          setState(() => _hovering = false);
          _updateThumbAnimation();
        },
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: (node, event) {
            _handleKeyEvent(event);
            return KeyEventResult.handled;
          },
          child: sliderContent,
        ),
      ),
    );
  }
}

class _SliderPainter extends CustomPainter {
  final double fraction;
  final double bufferedFraction;
  final double trackHeight;
  final double thumbRadius;
  final double borderRadius;
  final PoddrTrackShape trackShape;
  final Color activeColor;
  final Gradient? activeGradient;
  final Color inactiveColor;
  final Gradient? inactiveGradient;
  final Color bufferedColor;
  final Color thumbColor;
  final double thumbOpacity;
  final bool showThumb;
  final bool hasBuffered;

  _SliderPainter({
    required this.fraction,
    required this.bufferedFraction,
    required this.trackHeight,
    required this.thumbRadius,
    required this.borderRadius,
    required this.trackShape,
    required this.activeColor,
    required this.activeGradient,
    required this.inactiveColor,
    required this.inactiveGradient,
    required this.bufferedColor,
    required this.thumbColor,
    required this.thumbOpacity,
    required this.showThumb,
    required this.hasBuffered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || size.width.isNaN || size.height.isNaN) return;
    final centerY = size.height / 2;
    final trackRect = Rect.fromLTWH(0, centerY - trackHeight / 2, size.width, trackHeight);

    final clipRadius = trackShape == PoddrTrackShape.rounded ? borderRadius : 0.0;
    final clipRRect = RRect.fromRectAndRadius(trackRect, Radius.circular(clipRadius));

    canvas.save();
    canvas.clipRRect(clipRRect);

    if (inactiveGradient != null) {
      final paint = Paint()
        ..shader = inactiveGradient!.createShader(trackRect);
      canvas.drawRect(trackRect, paint);
    } else {
      final inactivePaint = Paint()..color = inactiveColor;
      canvas.drawRect(trackRect, inactivePaint);
    }

    if (hasBuffered && bufferedFraction > 0) {
      final bufferedWidth = size.width * bufferedFraction;
      final bufferedRect = Rect.fromLTWH(0, centerY - trackHeight / 2, bufferedWidth, trackHeight);
      final bufferedPaint = Paint()..color = bufferedColor;
      canvas.drawRect(bufferedRect, bufferedPaint);
    }

    final activeWidth = size.width * fraction;
    final activeRect = Rect.fromLTWH(0, centerY - trackHeight / 2, activeWidth, trackHeight);

    if (activeGradient != null) {
      final paint = Paint()
        ..shader = activeGradient!.createShader(activeRect);
      canvas.drawRect(activeRect, paint);
    } else {
      final activePaint = Paint()..color = activeColor;
      canvas.drawRect(activeRect, activePaint);
    }

    canvas.restore();

    if (showThumb) {
      final thumbX = activeWidth;
      final thumbPaint = Paint()
        ..color = thumbColor.withAlpha((thumbOpacity * 255).round());
      canvas.drawCircle(Offset(thumbX, centerY), thumbRadius, thumbPaint);
    }
  }

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.bufferedFraction != bufferedFraction ||
      oldDelegate.showThumb != showThumb ||
      oldDelegate.thumbOpacity != thumbOpacity ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.activeGradient != activeGradient ||
      oldDelegate.inactiveColor != inactiveColor ||
      oldDelegate.inactiveGradient != inactiveGradient ||
      oldDelegate.bufferedColor != bufferedColor ||
      oldDelegate.thumbColor != thumbColor;
}
