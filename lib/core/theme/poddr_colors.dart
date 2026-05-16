import 'package:flutter/widgets.dart';

class PoddrColors {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color surfaceContainer;
  final Color surfaceContainerLow;
  final Color surfaceContainerHigh;
  final Color surfaceContainerLowest;
  final Color surfaceContainerHighest;
  final Color outline;
  final Color error;
  final Color errorContainer;

  const PoddrColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.surfaceContainer,
    required this.surfaceContainerLow,
    required this.surfaceContainerHigh,
    required this.surfaceContainerLowest,
    required this.surfaceContainerHighest,
    required this.outline,
    required this.error,
    required this.errorContainer,
  });

  factory PoddrColors.light(Color seedColor) {
    final hsl = HSLColor.fromColor(seedColor);
    final primary = seedColor;
    final onPrimary = hsl.withLightness(0.05).toColor();
    final primaryContainer = hsl.withLightness(0.9).toColor();
    final onPrimaryContainer = hsl.withLightness(0.1).toColor();

    final secondaryHsl = hsl.withHue((hsl.hue + 15) % 360).withSaturation(
      (hsl.saturation * 0.6).clamp(0.0, 1.0),
    );
    final secondary = secondaryHsl.withLightness(0.6).toColor();
    final onSecondary = secondaryHsl.withLightness(0.05).toColor();

    final surface = const Color(0xFFFAFAFA);
    final onSurface = const Color(0xFF1C1C1C);
    final surfaceVariant = const Color(0xFFE7E0EC);
    final onSurfaceVariant = const Color(0xFF49454F);

    final surfaceContainerLowest = const Color(0xFFFFFFFF);
    final surfaceContainerLow = const Color(0xFFF7F2FA);
    final surfaceContainer = const Color(0xFFF3EDF7);
    final surfaceContainerHigh = const Color(0xFFECE6F0);
    final surfaceContainerHighest = const Color(0xFFE6E0E9);

    final outline = const Color(0xFF79747E);
    final error = const Color(0xFFBA1A1A);
    final errorContainer = const Color(0xFFFFDAD6);

    return PoddrColors(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      surfaceContainer: surfaceContainer,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerHighest: surfaceContainerHighest,
      outline: outline,
      error: error,
      errorContainer: errorContainer,
    );
  }

  factory PoddrColors.dark(Color seedColor) {
    final hsl = HSLColor.fromColor(seedColor);
    final primary = seedColor;
    final onPrimary = const Color.fromARGB(255, 15, 15, 15);
    final primaryContainer = hsl.withLightness(0.3).toColor();
    final onPrimaryContainer = const Color.fromARGB(255, 15, 15, 15);

    final secondaryHsl = hsl.withHue((hsl.hue + 15) % 360).withSaturation(
      (hsl.saturation * 0.6).clamp(0.0, 1.0),
    );
    final secondary = secondaryHsl.withLightness(0.7).toColor();
    final onSecondary = const Color.fromARGB(255, 15, 15, 15);

    final surface = const Color.fromRGBO(25, 25, 25, 1);
    final onSurface = const Color.fromARGB(255, 255, 255, 255);
    final surfaceVariant = const Color.fromRGBO(35, 35, 35, 1);
    final onSurfaceVariant = const Color.fromRGBO(200, 200, 200, 1);

    final surfaceContainerLowest = const Color.fromRGBO(20, 20, 20, 1);
    final surfaceContainerLow = const Color.fromRGBO(30, 30, 30, 1);
    final surfaceContainer = const Color.fromRGBO(40, 40, 40, 1);
    final surfaceContainerHigh = const Color.fromRGBO(50, 50, 50, 1);
    final surfaceContainerHighest = const Color.fromRGBO(60, 60, 60, 1);

    final outline = const Color.fromRGBO(120, 120, 120, 1);
    final error = const Color(0xFFFFB4AB);
    final errorContainer = const Color(0xFF93000A);

    return PoddrColors(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      surfaceContainer: surfaceContainer,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerHighest: surfaceContainerHighest,
      outline: outline,
      error: error,
      errorContainer: errorContainer,
    );
  }
}
