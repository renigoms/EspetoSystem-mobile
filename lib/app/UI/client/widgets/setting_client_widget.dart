import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingClientWidget extends StatelessWidget {
  final ThemeData theme;
  const SettingClientWidget({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(LucideIcons.edit, color: theme.colorScheme.tertiary),
            title: const Text('Editar dados'),
            onTap: () => Navigator.of(context).pop('edit'),
          ),
          ListTile(
            leading: Icon(LucideIcons.trash2, color: theme.colorScheme.error),
            title: Text(
              'Excluir cliente',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => Navigator.of(context).pop('delete'),
          ),
        ],
      ),
    );
  }
}
