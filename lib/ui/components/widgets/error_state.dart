import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/utils/gaps.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String title;
  final String retryLabel;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.title = 'Something went wrong',
    this.retryLabel = 'Try again',
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedAlertCircle,
            size: 48,
            color: theme.error,
          ),
          gapH16,
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium.copyWith(
              color: theme.onSurface,
            ),
          ),
          gapH8,
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium.copyWith(
              color: theme.onSurfaceVariant,
            ),
          ),
          if (onRetry != null) ...[
            gapH20,
            PoddrOutlinedButton(
              onPressed: onRetry,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedRefresh,
                    size: 18,
                    color: theme.primary,
                  ),
                  gapW8,
                  Text(retryLabel),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
