import 'package:flutter/widgets.dart';

class PoddrTextTheme {
  final TextStyle headlineSmall;
  final TextStyle titleMedium;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;

  const PoddrTextTheme({
    required this.headlineSmall,
    required this.titleMedium,
    required this.bodyMedium,
    required this.bodySmall,
  });

  factory PoddrTextTheme.light({String fontFamily = 'Outfit'}) {
    return PoddrTextTheme(
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1C1C1C),
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1C1C1C),
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF1C1C1C),
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF1C1C1C),
      ),
    );
  }

  factory PoddrTextTheme.dark({String fontFamily = 'Outfit'}) {
    return PoddrTextTheme(
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFFFFFF),
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFFFFFFF),
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFFFFFFF),
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFFFFFFF),
      ),
    );
  }
}
