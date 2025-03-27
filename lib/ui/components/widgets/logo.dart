import 'package:flutter/material.dart';

class PoddrLogo extends StatelessWidget {
  const PoddrLogo({super.key, this.size = 80});
  final double size;
  final double multiplier = 0.33;
  final double opacity = 0.6;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size.square(size),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            width: size * multiplier,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(opacity)
                    : Colors.black.withOpacity(opacity),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * multiplier),
                  topRight: Radius.circular(size * multiplier),
                  bottomLeft: Radius.circular(size * multiplier / 2),
                  bottomRight: Radius.circular(size * multiplier * 2),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size * multiplier,
            child: Container(
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.primary.withOpacity(opacity),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * multiplier),
                  topRight: Radius.circular(size * multiplier / 2),
                  bottomLeft: Radius.circular(size * multiplier),
                  bottomRight: Radius.circular(size * multiplier * 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
