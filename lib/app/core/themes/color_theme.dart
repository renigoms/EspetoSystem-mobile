import 'package:espetosystem/app/core/colors/app_colors.dart';
import 'package:flutter/material.dart';

final darkColorTheme = ThemeData().colorScheme.copyWith(
  brightness: Brightness.dark,
  surface: AppColorsEnum.carbomblack.color,
  onSurface: Colors.white, //Cor do texto
  primary: AppColorsEnum.jetblack.color,
  onPrimary: AppColorsEnum.carbomblackOpacit51Percent.color,
  secondary: AppColorsEnum.gunmetal.color,
  onSecondary: AppColorsEnum.whiteOpacit51percent.color,
  tertiary: AppColorsEnum.twitterblue.color,
  onTertiary: AppColorsEnum.platinum64percent.color,
  primaryContainer: Colors.black,
  onPrimaryContainer: AppColorsEnum.platinum24percent.color,
  error: AppColorsEnum.lobsterpink.color,
);
final lightColorTheme = ThemeData().colorScheme.copyWith(
  brightness: Brightness.light,
  surface: Colors.white,
  onSurface: Colors.black, //Cor do texto
  primary: AppColorsEnum.platinum.color,
  onPrimary: Colors.white,
  secondary: AppColorsEnum.platinum.color,
  onSecondary: Colors.black,
  tertiary: AppColorsEnum.twitterblue.color,
  onTertiary: AppColorsEnum.blackOpacit49percent.color,
  primaryContainer: Colors.black,
  onPrimaryContainer: AppColorsEnum.platinum24percent.color,
  error: AppColorsEnum.lobsterpink.color,
);
