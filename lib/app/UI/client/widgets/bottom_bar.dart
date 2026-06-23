import 'package:espetosystem/app/UI/client/view_model/client_account_view_model.dart';
import 'package:espetosystem/app/UI/client/widgets/client_detail_scope.dart';
import 'package:espetosystem/app/UI/client/widgets/nav_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class BottomBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const BottomBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final client = ClientDetailsScope.clientOf(context);
    final viewModel = context.watch<ClientAccountViewModel>();
    
    // Verifica se existem itens para liberar a aba de pagamentos
    final hasItems = viewModel.getItemsForClient(client.id ?? '').isNotEmpty;

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
            disabled: !hasItems, // Bloqueia se não houver itens
          ),
        ],
      ),
    );
  }
}
