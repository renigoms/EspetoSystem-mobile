import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final textTheme = ThemeData().textTheme.copyWith(
  titleLarge: GoogleFonts.roboto(
    textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  titleMedium: GoogleFonts.roboto(
    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
  ),

  labelSmall: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 12)),
  displaySmall: GoogleFonts.roboto(
    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
);
