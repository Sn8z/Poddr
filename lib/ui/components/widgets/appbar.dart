import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrAppBar extends StatelessWidget {
  const PoddrAppBar({
    super.key,
    required this.title,
    this.bottom,
    this.actions,
  });

  final Widget title;
  final List<Widget>? actions;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Semantics(
      header: true,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: theme.surfaceContainerHigh,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: DefaultTextStyle(
                      style: context.theme.textTheme.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      child: title,
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }
}
