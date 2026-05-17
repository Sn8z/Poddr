import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrFilledButton extends StatefulWidget {
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
  State<PoddrFilledButton> createState() => _PoddrFilledButtonState();
}

class _PoddrFilledButtonState extends State<PoddrFilledButton> {
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
    final baseColor = widget.backgroundColor ?? theme.primary;
    final fgColor = widget.foregroundColor ?? theme.onPrimary;

    Color bgColor = baseColor;
    if (_pressing) {
      bgColor = baseColor.withAlpha(204);
    } else if (_hovering) {
      bgColor = baseColor.withAlpha(230);
    }

    if (!_enabled) {
      bgColor = baseColor.withAlpha(102);
    }

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: _enabled,
      child: Focus(
        focusNode: _focusNode,
        child: MouseRegion(
          cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: GestureDetector(
            onTap: widget.onPressed,
            onLongPress: widget.onLongPress,
            onTapDown: _enabled ? (_) => setState(() => _pressing = true) : null,
            onTapUp: _enabled ? (_) => setState(() => _pressing = false) : null,
            onTapCancel: _enabled ? () => setState(() => _pressing = false) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: widget.padding,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                border: _focusNode.hasFocus
                    ? Border.all(color: theme.outline, width: 2)
                    : null,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: fgColor.withAlpha(_enabled ? 255 : 128),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
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

class PoddrElevatedButton extends StatefulWidget {
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
  State<PoddrElevatedButton> createState() => _PoddrElevatedButtonState();
}

class _PoddrElevatedButtonState extends State<PoddrElevatedButton> {
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
    final baseColor = widget.backgroundColor ?? theme.primary;
    final fgColor = widget.foregroundColor ?? theme.onPrimary;

    Color bgColor = baseColor;
    if (_pressing) {
      bgColor = baseColor.withAlpha(204);
    } else if (_hovering) {
      bgColor = baseColor.withAlpha(230);
    }

    if (!_enabled) {
      bgColor = baseColor.withAlpha(102);
    }

    final shadowOpacity = _pressing ? 0.15 : (_hovering ? 0.25 : 0.2);

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: _enabled,
      child: Focus(
        focusNode: _focusNode,
        child: MouseRegion(
          cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: GestureDetector(
            onTap: widget.onPressed,
            onLongPress: widget.onLongPress,
            onTapDown: _enabled ? (_) => setState(() => _pressing = true) : null,
            onTapUp: _enabled ? (_) => setState(() => _pressing = false) : null,
            onTapCancel: _enabled ? () => setState(() => _pressing = false) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: widget.padding,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x33000000).withAlpha((shadowOpacity * 255).round()),
                    blurRadius: _pressing ? 2 : 4,
                    offset: Offset(0, _pressing ? 1 : 2),
                  ),
                ],
                border: _focusNode.hasFocus
                    ? Border.all(color: theme.outline, width: 2)
                    : null,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: fgColor.withAlpha(_enabled ? 255 : 128),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
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

class PoddrOutlinedButton extends StatefulWidget {
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
  State<PoddrOutlinedButton> createState() => _PoddrOutlinedButtonState();
}

class _PoddrOutlinedButtonState extends State<PoddrOutlinedButton> {
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
    final baseBorderColor = widget.borderColor ?? theme.outline;
    final fgColor = widget.foregroundColor ?? theme.primary;
    final hoverBg = widget.hoverBackgroundColor ?? theme.primary.withAlpha(26);

    Color bgColor = const Color(0x00000000);
    Color borderColor = baseBorderColor;

    if (_pressing) {
      bgColor = hoverBg.withAlpha(153);
    } else if (_hovering) {
      bgColor = hoverBg;
    }

    if (!_enabled) {
      borderColor = baseBorderColor.withAlpha(102);
    }

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: _enabled,
      child: Focus(
        focusNode: _focusNode,
        child: MouseRegion(
          cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: GestureDetector(
            onTap: widget.onPressed,
            onLongPress: widget.onLongPress,
            onTapDown: _enabled ? (_) => setState(() => _pressing = true) : null,
            onTapUp: _enabled ? (_) => setState(() => _pressing = false) : null,
            onTapCancel: _enabled ? () => setState(() => _pressing = false) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: widget.padding,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                border: Border.all(
                  color: borderColor,
                  width: _focusNode.hasFocus ? 2 : 1,
                ),
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: fgColor.withAlpha(_enabled ? 255 : 128),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
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

class PoddrTextButton extends StatefulWidget {
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
  State<PoddrTextButton> createState() => _PoddrTextButtonState();
}

class _PoddrTextButtonState extends State<PoddrTextButton> {
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
    final baseColor = widget.color ?? theme.primary;

    Color textColor = baseColor;
    if (_pressing) {
      textColor = baseColor.withAlpha(179);
    } else if (_hovering) {
      textColor = baseColor.withAlpha(217);
    }

    if (!_enabled) {
      textColor = baseColor.withAlpha(102);
    }

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      button: true,
      enabled: _enabled,
      child: Focus(
        focusNode: _focusNode,
        child: MouseRegion(
          cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: GestureDetector(
            onTap: widget.onPressed,
            onLongPress: widget.onLongPress,
            onTapDown: _enabled ? (_) => setState(() => _pressing = true) : null,
            onTapUp: _enabled ? (_) => setState(() => _pressing = false) : null,
            onTapCancel: _enabled ? () => setState(() => _pressing = false) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: _focusNode.hasFocus
                    ? Border.all(color: theme.outline, width: 2)
                    : null,
              ),
              child: Text(
                widget.label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
