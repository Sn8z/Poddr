import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/utils/gaps.dart';

class PoddrDialog extends StatelessWidget {
  final Widget? header;
  final Widget child;
  final Widget? footer;
  final List<Widget>? actions;
  final double width;
  final EdgeInsets? contentPadding;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const PoddrDialog({
    super.key,
    this.header,
    required this.child,
    this.footer,
    this.actions,
    this.width = 600,
    this.contentPadding,
    this.showCloseButton = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    final dialogWidth = isSmallScreen ? screenSize.width - 32 : width;
    final dialogMaxHeight = screenSize.height - 32;

    final hasHeader = header != null || showCloseButton;
    final hasFooter =
        footer != null || (actions != null && actions!.isNotEmpty);

    return Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasHeader) ...[
              _buildHeader(context),
            ],
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: child,
                ),
              ),
            ),
            if (hasFooter) ...[
              _buildFooter(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (header != null) Expanded(child: header!),
          if (showCloseButton)
            PoddrIconButton(
              icon: const Icon(LucideIcons.x),
              onPressed: onClose ?? () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: footer ?? const SizedBox.shrink()),
          gapW8,
          Wrap(spacing: 8, runSpacing: 8, children: actions!),
        ],
      ),
    );
  }
}
