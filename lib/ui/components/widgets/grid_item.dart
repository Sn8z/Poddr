import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poddr/ui/utils/gaps.dart';

class PoddrGridItem extends StatefulWidget {
  const PoddrGridItem({
    super.key,
    this.width,
    this.height,
    this.title,
    this.titleMaxLines = 2,
    this.subtitle,
    this.subtitleMaxLines = 1,
    this.data,
    required this.leading,
    this.onTap,
    this.actions = const [],
    this.isActive = false,
  });
  final double? width;
  final double? height;
  final String? title;
  final int? titleMaxLines;
  final String? subtitle;
  final int? subtitleMaxLines;
  final Widget? data;
  final Widget leading;
  final VoidCallback? onTap;
  final List<Widget> actions;
  final bool isActive;

  @override
  State<PoddrGridItem> createState() => _PoddrListItemState();
}

class _PoddrListItemState extends State<PoddrGridItem> {
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
            width: widget.width ?? double.infinity,
            height: widget.height ?? double.infinity,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _isHovered || _isFocused || widget.isActive
                  ? Theme.of(context).colorScheme.surfaceContainerHigh
                  : Theme.of(context).colorScheme.surfaceContainer,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: widget.leading),
                gapH4,
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.title != null && widget.title!.isNotEmpty)
                            Text(
                              widget.title!,
                              maxLines: widget.titleMaxLines,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (widget.subtitle != null &&
                              widget.subtitle!.isNotEmpty)
                            Text(
                              widget.subtitle!,
                              maxLines: widget.subtitleMaxLines,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    ...widget.actions,
                  ],
                ),
                if (widget.data != null) widget.data!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
