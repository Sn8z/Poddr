import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/utils/gaps.dart';

enum StatusSeverity { info, warning, error }

class StatusBanner extends StatelessWidget {
  final String message;
  final StatusSeverity severity;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StatusBanner({
    super.key,
    required this.message,
    this.severity = StatusSeverity.info,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final Color bgColor;
    final Color borderColor;
    final Color iconColor;

    switch (severity) {
      case StatusSeverity.error:
        bgColor = theme.errorContainer.withAlpha(50);
        borderColor = theme.error.withAlpha(77);
        iconColor = theme.error;
      case StatusSeverity.warning:
        bgColor = theme.tertiaryContainer.withAlpha(50);
        borderColor = theme.tertiary.withAlpha(77);
        iconColor = theme.tertiary;
      case StatusSeverity.info:
        bgColor = theme.primaryContainer.withAlpha(50);
        borderColor = theme.primary.withAlpha(77);
        iconColor = theme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(
            icon: severity == StatusSeverity.error
                ? HugeIcons.strokeRoundedAlert01
                : HugeIcons.strokeRoundedAlertSquare,
            size: 18,
            color: iconColor,
          ),
          gapW12,
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall.copyWith(
                color: iconColor,
                height: 1.4,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            gapW12,
            PoddrTextButton(
              label: actionLabel!,
              color: iconColor,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
