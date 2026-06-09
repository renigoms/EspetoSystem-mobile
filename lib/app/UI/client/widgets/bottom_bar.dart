import 'package:espetosystem/app/UI/client/widgets/nav_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BottomBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const BottomBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(28, 6, 28, 8),
      color: theme.colorScheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavItem(
            label: 'Compras',
            icon: LucideIcons.shoppingCart,
            selected: navigationShell.currentIndex == 0,
            onTap: () => navigationShell.goBranch(0),
          ),
          NavItem(
            label: 'Pagamentos',
            icon: LucideIcons.banknote,
            selected: navigationShell.currentIndex == 1,
            onTap: () => navigationShell.goBranch(1),
          ),
        ],
      ),
    );
  }
}
