import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color get contrastTextColor {
    final brightness = ThemeData.estimateBrightnessForColor(this);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}