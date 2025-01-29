import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poddr/components/ui/image.dart';

class PoddrGridItem extends StatefulWidget {
  const PoddrGridItem(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.imageUri,
      required this.onTap,
      required this.actions});
  final String title;
  final String subtitle;
  final Uri imageUri;
  final VoidCallback onTap;
  final List<Widget> actions;

  @override
  State<PoddrGridItem> createState() => _PoddrGridItemState();
}

class _PoddrGridItemState extends State<PoddrGridItem> {
  final FocusNode _focusNode = FocusNode();
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: (value) {
        setState(
          () {
            _isFocused = value;
          },
        );
      },
      onKeyEvent: (_, event) {
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          widget.onTap();
          _focusNode.unfocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) => setState(() => _isHovered = true),
        onExit: (event) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: _isHovered
                ? Matrix4.identity()
                : Matrix4.translationValues(0, 4, 0),
            decoration: BoxDecoration(
              border: _isFocused
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              color: _isHovered
                  ? Theme.of(context).colorScheme.surfaceContainerHigh
                  : Theme.of(context).colorScheme.surfaceContainer,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: PoddrImage(
                              imageUri: widget.imageUri,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [...widget.actions],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
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
