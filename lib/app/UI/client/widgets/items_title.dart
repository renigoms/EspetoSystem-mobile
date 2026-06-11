import 'package:espetosystem/app/UI/client/view_model/client_account_view_model.dart';
import 'package:espetosystem/app/UI/client/widgets/client_detail_scope.dart';
import 'package:espetosystem/app/data/models/purchased_item_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class ItemsTitle extends StatelessWidget {
  const ItemsTitle({super.key, required this.onAdd});

  final Function(List<PurchasedItemModel>) onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Itens Comprados',
            style: GoogleFonts.roboto(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            final result = await context.push<List<Map<String, dynamic>>>(
              '/home/client/add-item',
            );

            if (result != null && context.mounted) {
              // Persiste no banco de dados e notifica o ViewModel
              final viewModel = context.read<ClientAccountViewModel>();
              final client = ClientDetailsScope.clientOf(context);
              if (client.id != null) {
                await viewModel.addItemsToClientAccount(client.id!, result);
              }
            }
          },
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 28, height: 28),
          padding: EdgeInsets.zero,
          tooltip: 'Adicionar item',
          icon: Icon(
            LucideIcons.badgePlus,
            color: theme.colorScheme.onSurface,
            size: 19,
          ),
        ),
      ],
    );
  }
}
