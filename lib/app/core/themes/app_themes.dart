import 'package:espetosystem/app/core/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final darkColorTheme = ThemeData().colorScheme.copyWith(
  surface: AppColorsEnum.jetblack.color,
  onSurface: Colors.white, //Cor do texto
  primary: AppColorsEnum.carbomblack.color,
  onPrimary: AppColorsEnum.carbomblackOpacit51Percent.color,
  secondary: AppColorsEnum.gunmetal.color,
);

final lightColorTheme = ThemeData().colorScheme.copyWith(surface: Colors.white);

final textTheme = ThemeData().textTheme.copyWith(
  titleLarge: GoogleFonts.roboto(
    textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  titleMedium: GoogleFonts.roboto(
    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
  ),
);
