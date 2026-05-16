import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrFilledButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PoddrFilledButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: foregroundColor ?? theme.onPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          child: IconTheme(
            data: IconThemeData(
              color: foregroundColor ?? theme.onPrimary,
              size: 20,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PoddrElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PoddrElevatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0x33000000),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: foregroundColor ?? theme.onPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          child: IconTheme(
            data: IconThemeData(
              color: foregroundColor ?? theme.onPrimary,
              size: 20,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PoddrOutlinedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? foregroundColor;

  const PoddrOutlinedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor ?? theme.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: foregroundColor ?? theme.primary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          child: IconTheme(
            data: IconThemeData(
              color: foregroundColor ?? theme.primary,
              size: 20,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PoddrTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const PoddrTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: color ?? context.theme.primary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
