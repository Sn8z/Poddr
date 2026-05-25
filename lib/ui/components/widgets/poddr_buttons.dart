import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrFilledButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  const PoddrFilledButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return _PoddrButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      baseColor: backgroundColor ?? theme.primary,
      foregroundColor: foregroundColor ?? theme.onPrimary,
      borderWidth: 0,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      padding: padding,
      child: child,
    );
  }
}

class PoddrElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  const PoddrElevatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return _PoddrButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      baseColor: backgroundColor ?? theme.primary,
      foregroundColor: foregroundColor ?? theme.onPrimary,
      borderWidth: 0,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      padding: padding,
      shadows: true,
      child: child,
    );
  }
}

class PoddrOutlinedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color? borderColor;
  final Color? foregroundColor;
  final Color? hoverBackgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  const PoddrOutlinedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.borderColor,
    this.foregroundColor,
    this.hoverBackgroundColor,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return _PoddrButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      baseColor: foregroundColor ?? theme.primary,
      foregroundColor: foregroundColor ?? theme.primary,
      borderColor: borderColor ?? theme.outline,
      borderWidth: 1,
      hoverBackgroundColor: hoverBackgroundColor ?? theme.primary.withAlpha(26),
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      padding: padding,
      child: child,
    );
  }
}

class PoddrTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color? color;
  final String? semanticLabel;

  const PoddrTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.onLongPress,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return _PoddrButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel ?? label,
      baseColor: color ?? theme.primary,
      foregroundColor: color ?? theme.primary,
      borderWidth: 0,
      borderRadius: BorderRadius.circular(4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      isTextButton: true,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          fontFamily: 'Outfit',
        ),
      ),
    );
  }
}

class _PoddrButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final Color baseColor;
  final Color foregroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Color? hoverBackgroundColor;
  final bool shadows;
  final bool isTextButton;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const _PoddrButton({
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.semanticLabel,
    required this.baseColor,
    required this.foregroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.hoverBackgroundColor,
    this.shadows = false,
    this.isTextButton = false,
    required this.borderRadius,
    required this.padding,
  });

  @override
  State<_PoddrButton> createState() => _PoddrButtonState();
}

class _PoddrButtonState extends State<_PoddrButton> {
  bool _hovering = false;
  bool _pressing = false;
  final _focusNode = FocusNode();

  bool get _enabled => widget.onPressed != null;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    Color bgColor;
    Color fgColor = widget.foregroundColor;
    Color borderColor = widget.borderColor ?? widget.foregroundColor;
    List<BoxShadow>? shadows;

    if (widget.isTextButton || widget.borderWidth > 0) {
      if (widget.isTextButton) {
        bgColor = const Color(0x00000000);
        fgColor = _pressing
            ? widget.baseColor.withAlpha(179)
            : _hovering
                ? widget.baseColor.withAlpha(217)
                : widget.baseColor;
      } else {
        final hoverBg =
            widget.hoverBackgroundColor ?? widget.baseColor.withAlpha(26);
        bgColor = _pressing
            ? hoverBg.withAlpha(153)
            : _hovering
                ? hoverBg
                : const Color(0x00000000);
        borderColor = _enabled
            ? widget.borderColor ?? widget.foregroundColor
            : (widget.borderColor ?? widget.foregroundColor).withAlpha(102);
        fgColor = widget.foregroundColor;
      }
    } else {
      bgColor = widget.baseColor;
      if (_pressing) {
        bgColor = bgColor.withAlpha(204);
      } else if (_hovering) {
        bgColor = bgColor.withAlpha(230);
      }

      if (!_enabled) {
        bgColor = bgColor.withAlpha(102);
      }
    }

    if (widget.shadows && _enabled) {
      final shadowOpacity = _pressing ? 0.15 : (_hovering ? 0.25 : 0.2);
      shadows = [
        BoxShadow(
          color: const Color(0x33000000)
              .withAlpha((shadowOpacity * 255).round()),
          blurRadius: _pressing ? 2 : 4,
          offset: Offset(0, _pressing ? 1 : 2),
        ),
      ];
    }

    final effectiveBorder = widget.borderWidth > 0 || _focusNode.hasFocus
        ? Border.all(
            color: _focusNode.hasFocus ? theme.outline : borderColor,
            width: _focusNode.hasFocus ? 2 : widget.borderWidth.clamp(0.5, 1),
          )
        : null;

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: _enabled,
      child: Focus(
        focusNode: _focusNode,
        child: MouseRegion(
          cursor:
              _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: GestureDetector(
            onTap: widget.onPressed,
            onLongPress: widget.onLongPress,
            onTapDown:
                _enabled ? (_) => setState(() => _pressing = true) : null,
            onTapUp:
                _enabled ? (_) => setState(() => _pressing = false) : null,
            onTapCancel:
                _enabled ? () => setState(() => _pressing = false) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: widget.padding,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: widget.borderRadius,
                border: effectiveBorder,
                boxShadow: shadows,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: fgColor.withAlpha(_enabled ? 255 : 128),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  fontFamily: 'Outfit',
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: fgColor.withAlpha(_enabled ? 255 : 128),
                    size: 20,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
