import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrLogo extends StatelessWidget {
  const PoddrLogo({super.key, this.size = 80});
  final double size;
  final double multiplier = 0.33;
  final double opacity = 0.6;

  @override
  Widget build(BuildContext context) {
    final imagePath = context.theme.brightness == Brightness.light
        ? 'assets/images/logo_dark.png'
        : 'assets/images/logo_light.png';

    return Image.asset(
      imagePath,
      width: size,
      height: size,
    );
  }
}
