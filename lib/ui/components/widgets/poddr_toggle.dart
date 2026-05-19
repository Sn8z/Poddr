import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final Color? indicatorColor;
  final Widget? leading;

  const PoddrToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.indicatorColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            if (label != null)
              Expanded(
                child: Text(
                  label!,
                  style: context.theme.textTheme.bodyMedium,
                ),
              ),
            if (label != null) const SizedBox(width: 12),
            Container(
              width: 40,
              height: 24,
              decoration: ShapeDecoration(
                color: indicatorColor ??
                    (value
                        ? context.theme.primary
                        : context.theme.surfaceContainerHighest),
                shape: RoundedSuperellipseBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.circular(24 / 3),
                ),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment:
                        value ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: ShapeDecoration(
                          color: context.theme.surface,
                          shape: RoundedSuperellipseBorder(
                            side: BorderSide.none,
                            borderRadius: BorderRadius.circular(20 / 3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
