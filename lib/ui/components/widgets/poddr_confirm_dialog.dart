import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';

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
    return PoddrDialog(
      header: Text(
        title,
        style: context.theme.textTheme.headlineSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: context.theme.secondary,
        ),
      ),
      actions: [
        PoddrTextButton(
          label: cancelLabel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        PoddrTextButton(
          label: confirmLabel,
          onPressed: onConfirm,
          color: context.theme.error,
        ),
      ],
      child: Text(
        message,
        style: context.theme.textTheme.bodyMedium.copyWith(
          color: context.theme.onSurfaceVariant,
        ),
      ),
    );
  }
}
