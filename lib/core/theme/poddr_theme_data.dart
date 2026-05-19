import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_colors.dart';
import 'package:poddr/core/theme/poddr_text_theme.dart';

enum PoddrThemeMode { system, light, dark }

@immutable
class PoddrThemeData {
  final Brightness brightness;
  final PoddrColors colors;
  final PoddrTextTheme textTheme;
  final String fontFamily;
  final IconThemeData iconTheme;

  const PoddrThemeData({
    required this.brightness,
    required this.colors,
    required this.textTheme,
    this.fontFamily = 'Outfit',
    this.iconTheme = const IconThemeData(size: 20),
  });

  factory PoddrThemeData.light(Color seedColor, {String fontFamily = 'Outfit'}) {
    final colors = PoddrColors.light(seedColor);
    return PoddrThemeData(
      brightness: Brightness.light,
      colors: colors,
      textTheme: PoddrTextTheme.light(fontFamily: fontFamily),
      fontFamily: fontFamily,
      iconTheme: IconThemeData(color: colors.onSurface, size: 20),
    );
  }

  factory PoddrThemeData.dark(Color seedColor, {String fontFamily = 'Outfit'}) {
    final colors = PoddrColors.dark(seedColor);
    return PoddrThemeData(
      brightness: Brightness.dark,
      colors: colors,
      textTheme: PoddrTextTheme.dark(fontFamily: fontFamily),
      fontFamily: fontFamily,
      iconTheme: IconThemeData(color: colors.onSurface, size: 20),
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
  Color get onError => colors.onError;
  Color get errorContainer => colors.errorContainer;
  Color get secondaryContainer => colors.secondaryContainer;
  Color get onSecondaryContainer => colors.onSecondaryContainer;
  Color get tertiary => colors.tertiary;
  Color get onTertiary => colors.onTertiary;
  Color get tertiaryContainer => colors.tertiaryContainer;
  Color get onTertiaryContainer => colors.onTertiaryContainer;
  Color get shadow => colors.shadow;
  Color get scrim => colors.scrim;

  PoddrThemeData copyWith({
    Brightness? brightness,
    PoddrColors? colors,
    PoddrTextTheme? textTheme,
    String? fontFamily,
    IconThemeData? iconTheme,
  }) {
    return PoddrThemeData(
      brightness: brightness ?? this.brightness,
      colors: colors ?? this.colors,
      textTheme: textTheme ?? this.textTheme,
      fontFamily: fontFamily ?? this.fontFamily,
      iconTheme: iconTheme ?? this.iconTheme,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PoddrThemeData &&
        other.brightness == brightness &&
        other.colors == colors &&
        other.textTheme == textTheme &&
        other.fontFamily == fontFamily &&
        other.iconTheme == iconTheme;
  }

  @override
  int get hashCode {
    return Object.hash(brightness, colors, textTheme, fontFamily, iconTheme);
  }
}
