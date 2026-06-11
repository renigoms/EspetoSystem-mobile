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
            title: Text('Editar dados', style: theme.textTheme.titleMedium),
            onTap: () => Navigator.of(context).pop('edit'),
          ),
          Divider(color: theme.colorScheme.onTertiary, thickness: 0.5),
          ListTile(
            leading: Icon(LucideIcons.trash2, color: theme.colorScheme.error),
            title: Text('Excluir cliente', style: theme.textTheme.titleMedium),
            onTap: () => Navigator.of(context).pop('delete'),
          ),
        ],
      ),
    );
  }
}
