import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrListItem extends StatefulWidget {
  const PoddrListItem({
    super.key,
    this.title,
    this.subtitle,
    this.data,
    this.leading,
    this.onTap,
    this.actions = const [],
    this.isActive = false,
  });
  final String? title;
  final String? subtitle;
  final Widget? data;
  final Widget? leading;
  final VoidCallback? onTap;
  final List<Widget> actions;
  final bool isActive;

  @override
  State<PoddrListItem> createState() => _PoddrListItemState();
}

class _PoddrListItemState extends State<PoddrListItem> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Focus(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter) {
              widget.onTap?.call();
              node.unfocus();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          onFocusChange: (focused) {
            setState(() {
              _isFocused = focused;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(8),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _isHovered || _isFocused || widget.isActive
                  ? context.theme.surfaceContainerHigh
                  : context.theme.surfaceContainer,
              gradient: widget.isActive
                  ? LinearGradient(
                      colors: [
                        context.theme.primary.withAlpha(50),
                        context.theme.primary.withAlpha(10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: Border(
                left: BorderSide(
                    width: 8,
                    color: widget.isActive
                        ? context.theme.primary
                        : const Color(0x00000000)),
              ),
            ),
            child: Row(
              children: [
                if (widget.leading != null)
                  SizedBox.fromSize(
                    size: const Size.square(48),
                    child: widget.leading,
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.subtitle != null &&
                            widget.subtitle!.isNotEmpty)
                          Text(
                            widget.subtitle!,
                            maxLines: 1,
                            style: context.theme.textTheme.labelMedium.copyWith(
                              color: context.theme.onSurfaceVariant,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (widget.title != null && widget.title!.isNotEmpty)
                          Text(
                            widget.title!,
                            maxLines: 2,
                            style: context.theme.textTheme.titleSmall.copyWith(
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (widget.data != null) widget.data!,
                      ],
                    ),
                  ),
                ),
                ...widget.actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
