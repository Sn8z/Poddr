import 'dart:math';
import 'package:flutter/widgets.dart';

Color generateRandomColor() {
  final random = Random();
  final hue = random.nextDouble() * 360;
  const saturation = 0.6;
  const lightness = 0.5;
  return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
}

int generateRandomColorInt() {
  return generateRandomColor().toARGB32();
}
