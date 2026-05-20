import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/utils/gaps.dart';

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          constraints: BoxConstraints(
            minHeight: 2,
            minWidth: 2,
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
                context.theme.surfaceContainer,
                context.theme.surfaceContainerHigh,
                context.theme.surfaceContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(widget.radius ?? 16),
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
