import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

Future<T?> showPoddrDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
  Color? barrierColor,
  double maxWidth = 400,
}) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    _PoddrDialogRoute(
      builder: builder,
      dismissible: dismissible,
      barrierColor: barrierColor,
      maxWidth: maxWidth,
    ),
  );
}

class _PoddrDialogRoute<T> extends PageRouteBuilder<T> {
  _PoddrDialogRoute({
    required WidgetBuilder builder,
    required bool dismissible,
    Color? barrierColor,
    double maxWidth = 400,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              _PoddrDialogPage(builder: builder, maxWidth: maxWidth),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          barrierDismissible: dismissible,
          barrierColor: barrierColor ?? const Color(0x80000000),
          opaque: false,
        );
}

class _PoddrDialogPage extends StatelessWidget {
  final WidgetBuilder builder;
  final double maxWidth;

  const _PoddrDialogPage({
    required this.builder,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
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
    );
  }
}
