import 'package:espetosystem/app/UI/client/view_model/client_view_model.dart';
import 'package:espetosystem/app/UI/client/widgets/build_header_cell.dart';
import 'package:espetosystem/app/UI/client/widgets/client_detail_scope.dart';
import 'package:espetosystem/app/UI/client/widgets/client_header.dart';
import 'package:espetosystem/app/UI/client/widgets/debt_summary_card.dart';
import 'package:espetosystem/app/UI/client/widgets/items_title.dart';
import 'package:espetosystem/app/UI/client/widgets/purchased_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ClientDetailsPage extends StatefulWidget {
  const ClientDetailsPage({super.key});

  @override
  State<ClientDetailsPage> createState() => _ClientDetailsPageState();
}

class _ClientDetailsPageState extends State<ClientDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Carrega os dados apenas uma vez ao entrar na tela
    Future.microtask(() {
      if (mounted) {
        final client = ClientDetailsScope.clientOf(context);
        if (client.id != null) {
          context.read<ClientViewModel>().loadItemsForClient(client.id!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = ClientDetailsScope.clientOf(context);
    // Observa o ViewModel para reconstruir a lista automaticamente
    final viewModel = context.watch<ClientViewModel>();
    final items = viewModel.getItemsForClient(client.id ?? '');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      children: [
        ClientHeader(client: client),
        const SizedBox(height: 22),
        const DebtSummaryCard(),
        const SizedBox(height: 28),
        ItemsTitle(
          onAdd: (_) {
            // A atualização agora é gerida inteiramente pelo ViewModel
            // para evitar conflitos de estado.
          },
        ),
        const SizedBox(height: 14),
        if (items.isEmpty && viewModel.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (items.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Nenhum item encontrado.',
                style: GoogleFonts.roboto(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ),
          )
        else ...[
          // Cabeçalho da Tabela
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                BuildHeaderCell('Qtd.', 1),
                BuildHeaderCell('Unid.', 1),
                BuildHeaderCell('Descrição', 2),
                BuildHeaderCell('V. Unit.', 2),
                BuildHeaderCell('Total', 2),
              ],
            ),
          ),
          ...items.map((item) => PurchasedItemTile(item: item)),
        ],
      ],
    );
  }
}
