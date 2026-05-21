import 'package:espetosystem/app/core/colors/app_colors.dart';
import 'package:flutter/material.dart';

final darkColorTheme = ThemeData().colorScheme.copyWith(
  surface: AppColorsEnum.jetblack.color,
  onSurface: Colors.white, //Cor do texto
  primary: AppColorsEnum.carbomblack.color,
  onPrimary: AppColorsEnum.carbomblackOpacit51Percent.color,
  secondary: AppColorsEnum.gunmetal.color,
  onSecondary: AppColorsEnum.whiteOpacit51percent.color,
  tertiary: AppColorsEnum.twitterblue.color,
  onTertiary: AppColorsEnum.platinum64percent.color,
  primaryContainer: Colors.black,
  onPrimaryContainer: AppColorsEnum.platinum24percent.color,
  error: AppColorsEnum.lobsterpink.color,
);
final lightColorTheme = ThemeData().colorScheme.copyWith(surface: Colors.white);
