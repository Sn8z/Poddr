import 'package:flutter/widgets.dart';

class PoddrTextTheme {
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  const PoddrTextTheme({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  factory PoddrTextTheme.light({String fontFamily = 'Outfit'}) {
    final lightColor = const Color(0xFF1C1C1C);
    return PoddrTextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily, fontSize: 57, fontWeight: FontWeight.w400, color: lightColor,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily, fontSize: 45, fontWeight: FontWeight.w400, color: lightColor,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily, fontSize: 36, fontWeight: FontWeight.w400, color: lightColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily, fontSize: 32, fontWeight: FontWeight.w600, color: lightColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w600, color: lightColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w600, color: lightColor,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.w500, color: lightColor,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w500, color: lightColor,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: lightColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400, color: lightColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400, color: lightColor,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400, color: lightColor,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: lightColor,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: lightColor,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily, fontSize: 10, fontWeight: FontWeight.w500, color: lightColor,
      ),
    );
  }

  factory PoddrTextTheme.dark({String fontFamily = 'Outfit'}) {
    final darkColor = const Color(0xFFFFFFFF);
    return PoddrTextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily, fontSize: 57, fontWeight: FontWeight.w400, color: darkColor,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily, fontSize: 45, fontWeight: FontWeight.w400, color: darkColor,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily, fontSize: 36, fontWeight: FontWeight.w400, color: darkColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily, fontSize: 32, fontWeight: FontWeight.w600, color: darkColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w600, color: darkColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w600, color: darkColor,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.w500, color: darkColor,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w500, color: darkColor,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: darkColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400, color: darkColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400, color: darkColor,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400, color: darkColor,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: darkColor,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: darkColor,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily, fontSize: 10, fontWeight: FontWeight.w500, color: darkColor,
      ),
    );
  }

  PoddrTextTheme copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
  }) {
    return PoddrTextTheme(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
    );
  }
}
