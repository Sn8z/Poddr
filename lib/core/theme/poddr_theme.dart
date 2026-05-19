import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme_data.dart';

class PoddrTheme extends StatelessWidget {
  final PoddrThemeData data;
  final Widget child;

  const PoddrTheme({
    super.key,
    required this.child,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return _PoddrThemeInherited(
      data: data,
      child: IconTheme(
        data: data.iconTheme,
        child: child,
      ),
    );
  }
}

class _PoddrThemeInherited extends InheritedWidget {
  final PoddrThemeData data;

  const _PoddrThemeInherited({
    required super.child,
    required this.data,
  });

  static PoddrThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<_PoddrThemeInherited>();
    assert(theme != null, 'No PoddrTheme found in context');
    return theme!.data;
  }

  @override
  bool updateShouldNotify(_PoddrThemeInherited oldWidget) => data != oldWidget.data;
}

extension PoddrThemeX on BuildContext {
  PoddrThemeData get theme => _PoddrThemeInherited.of(this);
}
