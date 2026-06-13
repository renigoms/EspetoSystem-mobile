import 'package:flutter/material.dart';

class StatusTag extends StatelessWidget {
  const StatusTag({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String displayStatus = status.toUpperCase();

    switch (status.toUpperCase()) {
      case 'DEVENDO':
        backgroundColor = theme.colorScheme.error;
        textColor = Colors.white;
        displayStatus = 'DEVENDO';
        break;
      case 'PAGO':
      case 'PAGA':
        backgroundColor = theme.colorScheme.tertiary;
        textColor = Colors.white;
        displayStatus = 'PAGO';
        break;
      case 'LIMPO':
      case 'LIMPA':
      default:
        backgroundColor = theme.colorScheme.onSecondary.withValues(alpha: 0.15);
        textColor = theme.colorScheme.onSurface.withValues(alpha: 0.7);
        displayStatus = 'LIMPO';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayStatus,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
