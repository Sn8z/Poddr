import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
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
    this.semanticLabel,
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
  final String? semanticLabel;

  @override
  State<PoddrGridItem> createState() => _PoddrGridItemState();
}

class _PoddrGridItemState extends State<PoddrGridItem> {
  bool _isHovered = false;
  bool _isFocused = false;

  bool get _enabled => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? widget.title,
      button: true,
      enabled: _enabled,
      child: MouseRegion(
        cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: Focus(
            onKeyEvent: (node, event) {
              if (_enabled &&
                  event is KeyDownEvent &&
                  (event.logicalKey == LogicalKeyboardKey.enter ||
                      event.logicalKey == LogicalKeyboardKey.space)) {
                widget.onTap?.call();
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _isHovered || _isFocused || widget.isActive
                    ? context.theme.surfaceContainerHigh
                    : context.theme.surfaceContainer,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Stack(
                      children: [
                        widget.leading,
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: SizedBox(
                            height: 8,
                            child: widget.data ?? const SizedBox(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  gapH4,
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.title != null &&
                                widget.title!.isNotEmpty)
                              Text(
                                widget.title!,
                                maxLines: widget.titleMaxLines,
                                style:
                                    context.theme.textTheme.titleSmall.copyWith(
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            if (widget.subtitle != null &&
                                widget.subtitle!.isNotEmpty)
                              Text(
                                widget.subtitle!,
                                maxLines: widget.subtitleMaxLines,
                                style: context.theme.textTheme.labelMedium
                                    .copyWith(
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                      ...widget.actions,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
