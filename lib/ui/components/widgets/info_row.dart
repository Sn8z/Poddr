import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/utils/gaps.dart';

class PoddrInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? action;

  const PoddrInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.outline.withAlpha(30),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.primary),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.theme.textTheme.bodySmall.copyWith(
                          color: theme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  gapH4,
                  Text(
                    value,
                    style: context.theme.textTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
            if (action != null) ...[
              gapW8,
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
