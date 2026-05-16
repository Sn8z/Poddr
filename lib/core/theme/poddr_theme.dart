import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme_data.dart';

class PoddrTheme extends InheritedWidget {
  final PoddrThemeData data;

  const PoddrTheme({
    super.key,
    required super.child,
    required this.data,
  });

  static PoddrThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<PoddrTheme>();
    assert(theme != null, 'No PoddrTheme found in context');
    return theme!.data;
  }

  @override
  bool updateShouldNotify(PoddrTheme oldWidget) => data != oldWidget.data;
}

extension PoddrThemeX on BuildContext {
  PoddrThemeData get theme => PoddrTheme.of(this);
}
