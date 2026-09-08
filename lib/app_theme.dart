import 'package:flutter/material.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xffd6533f),
    brightness: brightness,
  );

  return ThemeData(
    colorScheme: scheme,
    brightness: brightness,
    scaffoldBackgroundColor: brightness == Brightness.light
        ? const Color(0xfffffbf7)
        : const Color(0xff171514),
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
    cardTheme: const CardThemeData(margin: EdgeInsets.zero, elevation: 0),
  );
}
