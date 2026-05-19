import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrIconButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double size;
  final double? iconSize;
  final double? padding;
  final Color? color;
  final Color? hoverColor;
  final Color? pressColor;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  const PoddrIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.onLongPress,
    this.size = 20,
    this.iconSize,
    this.padding,
    this.color,
    this.hoverColor,
    this.pressColor,
    this.borderRadius,
    this.semanticLabel,
  });

  @override
  State<PoddrIconButton> createState() => _PoddrIconButtonState();
}

class _PoddrIconButtonState extends State<PoddrIconButton> {
  bool _hovering = false;
  bool _pressing = false;
  final _focusNode = FocusNode();

  bool get _enabled => widget.onPressed != null;

  double get _effectivePadding => widget.padding ?? 8;
  double get _effectiveIconSize => widget.iconSize ?? widget.size;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final baseColor = widget.color ?? theme.primary;
    final hoverBg = widget.hoverColor ?? baseColor.withAlpha(26);
    final pressBg = widget.pressColor ?? baseColor.withAlpha(51);

    Color bgColor = const Color(0x00000000);
    Color iconColor = baseColor;

    if (_pressing) {
      bgColor = pressBg;
      iconColor = baseColor.withAlpha(204);
    } else if (_hovering) {
      bgColor = hoverBg;
      iconColor = baseColor.withAlpha(230);
    }

    if (!_enabled) {
      bgColor = const Color(0x00000000);
      iconColor = baseColor.withAlpha(102);
    }

    final totalSize = widget.size + _effectivePadding * 2;
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(totalSize / 3);

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: _enabled,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (_enabled &&
              event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            widget.onPressed?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
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
            onTapUp: _enabled ? (_) => setState(() => _pressing = false) : null,
            onTapCancel:
                _enabled ? () => setState(() => _pressing = false) : null,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: totalSize,
              height: totalSize,
              decoration: ShapeDecoration(
                color: bgColor,
                shape: RoundedSuperellipseBorder(
                  side: _focusNode.hasFocus
                      ? BorderSide(color: theme.outline, width: 2)
                      : BorderSide.none,
                  borderRadius: effectiveBorderRadius,
                ),
              ),
              child: Semantics(
                excludeSemantics: true,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: _effectiveIconSize,
                      color: iconColor,
                    ),
                    child: widget.icon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
