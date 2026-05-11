import 'package:flutter/material.dart';

buttonStyleBlue(ThemeData theme) => ButtonStyle(
  shape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
  ),

  backgroundColor: WidgetStateProperty.all(theme.colorScheme.tertiary),
);
