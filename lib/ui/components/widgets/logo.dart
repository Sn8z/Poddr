import 'package:flutter/material.dart';

class PoddrLogo extends StatelessWidget {
  const PoddrLogo({super.key, this.size = 80});
  final double size;
  final double multiplier = 0.33;
  final double opacity = 0.6;

  @override
  Widget build(BuildContext context) {
    final imagePath = Theme.of(context).brightness == Brightness.light
        ? 'assets/images/logo_dark.png'
        : 'assets/images/logo_white.png';

    return Image.asset(
      imagePath,
      width: size,
      height: size,
    );
  }
}
