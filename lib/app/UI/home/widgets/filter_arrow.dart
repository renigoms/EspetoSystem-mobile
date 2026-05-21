import 'package:espetosystem/app/UI/home/components/components.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FilterArrow extends StatelessWidget {
  final ThemeData theme;
  const FilterArrow({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 31,
      height: 31,
      decoration: decorationContainerCustom(theme),
      child: Icon(LucideIcons.arrowUp, color: theme.colorScheme.onSurface),
    );
  }
}
