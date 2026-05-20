import 'package:flutter/widgets.dart';

Future<T?> showPoddrDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
  Color? barrierColor,
}) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    _PoddrDialogRoute(
      builder: builder,
      dismissible: dismissible,
      barrierColor: barrierColor,
    ),
  );
}

class _PoddrDialogRoute<T> extends PageRouteBuilder<T> {
  _PoddrDialogRoute({
    required WidgetBuilder builder,
    required bool dismissible,
    Color? barrierColor,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              _PoddrDialogPage(builder: builder),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          barrierDismissible: dismissible,
          barrierColor: barrierColor ?? const Color(0x80000000),
          opaque: false,
        );
}

class _PoddrDialogPage extends StatelessWidget {
  final WidgetBuilder builder;

  const _PoddrDialogPage({
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: builder(context),
    );
  }
}
