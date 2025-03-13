import 'package:flutter/material.dart';

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({super.key, this.height, this.width});

  final double? height;
  final double? width;

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          constraints: BoxConstraints(
            minHeight: 50,
            minWidth: 50,
            maxHeight: widget.height ?? double.infinity,
            maxWidth: widget.width ?? double.infinity,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              transform: const GradientRotation(0.5),
              stops: [
                _controller.value - 0.1,
                _controller.value,
                _controller.value + 0.1,
              ],
              colors: [
                Theme.of(context).colorScheme.surfaceContainer,
                Theme.of(context).colorScheme.surfaceContainerHigh,
                Theme.of(context).colorScheme.surfaceContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
