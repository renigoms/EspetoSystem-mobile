import 'package:flutter/material.dart';

class ConfirmDialogWidget extends StatelessWidget {
  final ThemeData theme;
  const ConfirmDialogWidget({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: theme.colorScheme.secondary,
      insetPadding: const EdgeInsets.all(24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Excluir cliente', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16.0),
            Text(
              'Tem certeza que deseja excluir este cliente? Esta ação não pode ser desfeita.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.40,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancelar',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Excluir',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
