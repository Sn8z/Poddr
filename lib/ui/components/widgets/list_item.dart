import 'package:flutter/material.dart';

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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _isHovered || _isFocused || widget.isActive
                  ? Theme.of(context).colorScheme.surfaceContainerHigh
                  : Theme.of(context).colorScheme.surfaceContainer,
              border: Border(
                left: BorderSide(
                    width: 8,
                    color: widget.isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent),
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
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (widget.title != null && widget.title!.isNotEmpty)
                          Text(
                            widget.title!,
                            maxLines: 2,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
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
