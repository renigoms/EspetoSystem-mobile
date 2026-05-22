import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SearchBarStaticCustom extends StatelessWidget {
  final ThemeData theme;
  const SearchBarStaticCustom({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: theme.colorScheme.onSecondary, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          spacing: 10,
          children: [
            Icon(LucideIcons.search, color: theme.colorScheme.onSecondary),
            Text(
              "Buscar cliente ou descrição...",
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
