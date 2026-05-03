import 'package:flutter/material.dart';

enum AppColorsEnum {
  carbomblack(Color(0x00252525)),
  jetblack(Color(0x00292929)),
  gunmetal(Color(0x003C3C3C)),
  twitterblue(Color(0x000078D7)),
  lobsterpink(Color(0x00D9534F)),
  platinum(Color(0x00F2F5F9));

  final Color color;

  const AppColorsEnum(this.color);

  static ColorScheme darkColorTheme() => ThemeData().colorScheme.copyWith(
    primary: AppColorsEnum.jetblack.color,
    onPrimary: Colors.white,
    secondary: AppColorsEnum.twitterblue.color,
    onSecondary: Colors.white,
    surface: AppColorsEnum.gunmetal.color,
    onSurface: Colors.white,
    error: AppColorsEnum.lobsterpink.color,
    tertiary: AppColorsEnum.twitterblue.color,
  );

  static ColorScheme lightColorTheme() => ThemeData().colorScheme.copyWith();
}
