import 'package:flutter/material.dart';

class ThemeColor {
  final String name;
  final Color color;

  ThemeColor(this.name, this.color);
}

final List<ThemeColor> colors = [
  ThemeColor('Orange', const Color.fromARGB(255, 255, 150, 30)),
  ThemeColor('Coral', const Color.fromARGB(255, 239, 76, 76)),
  ThemeColor('Red', const Color.fromARGB(255, 255, 30, 30)),
  ThemeColor('Pink', const Color.fromARGB(255, 255, 30, 150)),
  ThemeColor('Purple', const Color.fromARGB(255, 255, 30, 255)),
  ThemeColor('Violet', const Color.fromARGB(255, 255, 150, 255)),
  ThemeColor('Blue', const Color.fromARGB(255, 30, 150, 255)),
  ThemeColor('Cyan', const Color.fromARGB(255, 30, 255, 255)),
  ThemeColor('Teal', const Color.fromARGB(255, 30, 255, 150)),
  ThemeColor('Green', const Color.fromARGB(255, 30, 255, 30)),
  ThemeColor('Yellow', const Color.fromARGB(255, 255, 255, 30)),
];
