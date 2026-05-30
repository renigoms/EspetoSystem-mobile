import 'package:flutter/material.dart';

class LabelTitle extends StatelessWidget {
  final ThemeData theme;
  final String title;
  const LabelTitle({super.key, required this.theme, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(children: [Text(title, style: theme.textTheme.titleLarge)]),
    );
  }
}
