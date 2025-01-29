import 'package:flutter/material.dart';

class PoddrLogo extends StatelessWidget {
  const PoddrLogo({super.key, this.size = 80});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: Theme.of(context).brightness == Brightness.dark
          ? const AssetImage('assets/images/logo_white.png')
          : const AssetImage('assets/images/logo_dark.png'),
      width: size,
      height: size,
    );
  }
}
