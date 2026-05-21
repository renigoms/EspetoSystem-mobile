import 'package:flutter/material.dart';

BoxDecoration decorationContainerCustom(ThemeData theme) => BoxDecoration(
  border: Border.all(color: theme.colorScheme.onSecondary),
  borderRadius: BorderRadius.circular(6),
);
