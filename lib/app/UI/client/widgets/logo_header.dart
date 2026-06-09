import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  final ThemeData theme;
  const LogoHeader(this.theme, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 8,
      children: [
        Image.asset('assets/images/logo.png', width: 31, height: 41),
        Row(
          children: [
            Text("Espeto", style: TextStyle(color: theme.colorScheme.error)),
            Text("System", style: TextStyle(color: theme.colorScheme.tertiary)),
          ],
        ),
      ],
    );
  }
}
