import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

Future<T?> showPoddrDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  return Navigator.of(context).push<T>(
    _PoddrDialogRoute(
      builder: builder,
      dismissible: dismissible,
    ),
  );
}

class _PoddrDialogRoute<T> extends PageRouteBuilder<T> {
  _PoddrDialogRoute({
    required WidgetBuilder builder,
    required bool dismissible,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              _PoddrDialogPage(builder: builder, dismissible: dismissible),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          barrierDismissible: dismissible,
          barrierColor: const Color(0x80000000),
        );
}

class _PoddrDialogPage extends StatelessWidget {
  final WidgetBuilder builder;
  final bool dismissible;

  const _PoddrDialogPage({
    required this.builder,
    required this.dismissible,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: GestureDetector(
          onTap: dismissible ? () => Navigator.of(context).pop() : null,
          child: Container(
            decoration: BoxDecoration(
              color: context.theme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(12),
            child: builder(context),
          ),
        ),
      ),
    );
  }
}
