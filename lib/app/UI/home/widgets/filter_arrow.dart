import 'package:espetosystem/app/UI/home/components/decorations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FilterArrow extends StatelessWidget {
  final ThemeData theme;
  final bool isAscending;
  final VoidCallback onTap;

  const FilterArrow({
    super.key,
    required this.theme,
    required this.isAscending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 31,
        height: 31,
        decoration: decorationContainerCustom(theme),
        child: Icon(
          isAscending ? LucideIcons.arrowDown : LucideIcons.arrowUp,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
