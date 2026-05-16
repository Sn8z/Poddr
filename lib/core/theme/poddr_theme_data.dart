import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_colors.dart';
import 'package:poddr/core/theme/poddr_text_theme.dart';

@immutable
class PoddrThemeData {
  final Brightness brightness;
  final PoddrColors colors;
  final PoddrTextTheme textTheme;
  final String fontFamily;

  const PoddrThemeData({
    required this.brightness,
    required this.colors,
    required this.textTheme,
    this.fontFamily = 'Outfit',
  });

  factory PoddrThemeData.light(Color seedColor, {String fontFamily = 'Outfit'}) {
    final colors = PoddrColors.light(seedColor);
    return PoddrThemeData(
      brightness: Brightness.light,
      colors: colors,
      textTheme: PoddrTextTheme.light(fontFamily: fontFamily),
      fontFamily: fontFamily,
    );
  }

  factory PoddrThemeData.dark(Color seedColor, {String fontFamily = 'Outfit'}) {
    final colors = PoddrColors.dark(seedColor);
    return PoddrThemeData(
      brightness: Brightness.dark,
      colors: colors,
      textTheme: PoddrTextTheme.dark(fontFamily: fontFamily),
      fontFamily: fontFamily,
    );
  }

  Color get primary => colors.primary;
  Color get onPrimary => colors.onPrimary;
  Color get primaryContainer => colors.primaryContainer;
  Color get onPrimaryContainer => colors.onPrimaryContainer;
  Color get secondary => colors.secondary;
  Color get onSecondary => colors.onSecondary;
  Color get surface => colors.surface;
  Color get onSurface => colors.onSurface;
  Color get surfaceVariant => colors.surfaceVariant;
  Color get onSurfaceVariant => colors.onSurfaceVariant;
  Color get surfaceContainer => colors.surfaceContainer;
  Color get surfaceContainerLow => colors.surfaceContainerLow;
  Color get surfaceContainerHigh => colors.surfaceContainerHigh;
  Color get surfaceContainerLowest => colors.surfaceContainerLowest;
  Color get surfaceContainerHighest => colors.surfaceContainerHighest;
  Color get outline => colors.outline;
  Color get error => colors.error;
  Color get errorContainer => colors.errorContainer;

  PoddrThemeData copyWith({
    Brightness? brightness,
    PoddrColors? colors,
    PoddrTextTheme? textTheme,
    String? fontFamily,
  }) {
    return PoddrThemeData(
      brightness: brightness ?? this.brightness,
      colors: colors ?? this.colors,
      textTheme: textTheme ?? this.textTheme,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PoddrThemeData &&
        other.brightness == brightness &&
        other.colors == colors &&
        other.textTheme == textTheme &&
        other.fontFamily == fontFamily;
  }

  @override
  int get hashCode {
    return Object.hash(brightness, colors, textTheme, fontFamily);
  }
}
