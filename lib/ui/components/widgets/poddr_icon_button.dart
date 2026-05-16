import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;

  const PoddrIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 26,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size + 16,
        height: size + 16,
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              size: size,
              color: color ?? context.theme.onSurface,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}
