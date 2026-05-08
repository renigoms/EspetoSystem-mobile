import 'package:flutter/material.dart';

InputDecoration formFieldDecoration(ThemeData theme, Widget? sufixIcon) =>
    InputDecoration(
      suffixIcon: sufixIcon,
      filled: true,
      fillColor: theme.colorScheme.onPrimary,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: theme.colorScheme.onSecondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: theme.colorScheme.tertiary),
      ),
    );
