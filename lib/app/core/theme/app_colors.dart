import 'package:flutter/material.dart';

enum AppColorsEnum {
  carbomblack(Color(0xFF252525)),
  jetblack(Color(0xFF292929)),
  gunmetal(Color(0xFF3C3C3C)),
  twitterblue(Color(0xFF0078D7)),
  lobsterpink(Color(0xFFD9534F)),
  platinum(Color(0xFFF2F5F9));

  final Color color;

  const AppColorsEnum(this.color);

  static final darkColorTheme = ThemeData().colorScheme.copyWith(
    primary: AppColorsEnum.jetblack.color,
    onPrimary: Colors.white,
    secondary: const Color(0xFF0076D7),
    onSecondary: Colors.white,
    surface: AppColorsEnum.jetblack.color,
    onSurface: Colors.white,
    error: const Color(0xFFD9544F),
    tertiary: const Color(0xFF0076D7),
  );

  static final lightColorTheme = ThemeData().colorScheme.copyWith();
}
