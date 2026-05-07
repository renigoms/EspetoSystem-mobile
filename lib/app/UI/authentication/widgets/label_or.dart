import 'package:flutter/material.dart';

class LabelOr extends StatelessWidget {
  final ThemeData theme;
  const LabelOr({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.onSecondary),
          ),

          height: 0,
          width: 125,
        ),
        Text("OU", style: theme.textTheme.labelSmall),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.onSecondary),
          ),
          height: 0,
          width: 125,
        ),
      ],
    );
  }
}
