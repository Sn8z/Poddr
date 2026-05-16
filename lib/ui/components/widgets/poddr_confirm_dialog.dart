import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';

class PoddrConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const PoddrConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Confirm',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: context.theme.textTheme.bodyMedium.copyWith(
            color: context.theme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PoddrTextButton(
              label: cancelLabel,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            PoddrTextButton(
              label: confirmLabel,
              onPressed: onConfirm,
              color: context.theme.error,
            ),
          ],
        ),
      ],
    );
  }
}
