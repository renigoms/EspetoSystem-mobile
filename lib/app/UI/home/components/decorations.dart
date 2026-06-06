import 'package:flutter/material.dart';

BoxDecoration decorationContainerCustom(ThemeData theme) => BoxDecoration(
  color: theme.colorScheme.primary,
  border: Border.all(color: theme.colorScheme.onSecondary),
  borderRadius: BorderRadius.circular(6),
);
