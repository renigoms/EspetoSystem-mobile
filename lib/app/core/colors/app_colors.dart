import 'package:flutter/material.dart';

enum AppColorsEnum {
  carbomblack(Color(0xFF252525)),
  carbomblackOpacit51Percent(Color(0x82252525)),
  jetblack(Color(0xFF292929)),
  gunmetal(Color(0xFF3C3C3C)),
  twitterblue(Color(0xFF0078D7)),
  lobsterpink(Color(0xFFD9534F)),
  platinum(Color(0xFFF2F5F9)),
  blackOpacit25percent(Color(0x40000000));

  final Color color;

  const AppColorsEnum(this.color);
}
