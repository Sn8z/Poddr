import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/utils/gaps.dart';

Future<void> showPoddrErrorDialog({
  required BuildContext context,
  required String message,
  String title = 'Something went wrong',
}) {
  return showPoddrDialog<void>(
    context: context,
    builder: (dialogContext) {
      return PoddrDialog(
        header: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedAlertCircle,
              size: 24,
              color: dialogContext.theme.error,
            ),
            gapW8,
            Expanded(
              child: Text(
                title,
                style: dialogContext.theme.textTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dialogContext.theme.secondary,
                ),
              ),
            ),
          ],
        ),
        showCloseButton: true,
        actions: [
          PoddrTextButton(
            label: 'OK',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
        child: Text(
          message,
          style: dialogContext.theme.textTheme.bodyMedium.copyWith(
            color: dialogContext.theme.onSurfaceVariant,
          ),
        ),
      );
    },
  );
}
