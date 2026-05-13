import 'package:flutter/material.dart';

class CheckPasswordRow extends StatelessWidget {
  final String text;
  final ThemeData theme;
  final bool isValid;

  const CheckPasswordRow({
    super.key,
    required this.text,
    required this.theme,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check : Icons.close,
          color: isValid ? theme.colorScheme.tertiary : theme.colorScheme.error,
        ),
        Text(
          text,
          style: theme.textTheme.labelSmall,
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
