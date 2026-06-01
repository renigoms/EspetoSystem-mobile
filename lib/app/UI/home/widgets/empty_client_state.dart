import 'package:flutter/material.dart';

class EmptyClientState extends StatelessWidget {
  const EmptyClientState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        'Nenhum cliente encontrado.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
