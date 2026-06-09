import 'package:espetosystem/app/UI/client/view_model/client_view_model.dart';
import 'package:espetosystem/app/UI/client/widgets/add_payment_dialog.dart';
import 'package:espetosystem/app/UI/client/widgets/build_header_cell.dart';
import 'package:espetosystem/app/UI/client/widgets/client_detail_scope.dart';
import 'package:espetosystem/app/UI/client/widgets/client_header.dart';
import 'package:espetosystem/app/UI/client/widgets/debt_summary_card.dart';
import 'package:espetosystem/app/UI/client/widgets/payment_tile.dart';
import 'package:espetosystem/app/UI/client/widgets/payments_title.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ClientPaymentsPage extends StatefulWidget {
  const ClientPaymentsPage({super.key});

  @override
  State<ClientPaymentsPage> createState() => _ClientPaymentsPageState();
}

class _ClientPaymentsPageState extends State<ClientPaymentsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final client = ClientDetailsScope.clientOf(context);
        if (client.id != null) {
          context.read<ClientViewModel>().loadItemsForClient(
            client.id!,
          ); // This also loads payments
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = ClientDetailsScope.clientOf(context);
    final viewModel = context.watch<ClientViewModel>();
    final payments = viewModel.getPaymentsForClient(client.id ?? '');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      children: [
        ClientHeader(client: client),
        const SizedBox(height: 22),
        const DebtSummaryCard(),
        const SizedBox(height: 28),
        PaymentsTitle(
          onAdd: () async {
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (context) => const AddPaymentDialog(),
            );

            if (result != null && context.mounted) {
              final viewModel = context.read<ClientViewModel>();
              if (client.id != null) {
                await viewModel.addPaymentToClientAccount(client.id!, result);
              }
            }
          },
        ),
        const SizedBox(height: 14),
        if (payments.isEmpty && viewModel.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (payments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Nenhum pagamento registrado.',
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
                BuildHeaderCell('Data', 1),
                BuildHeaderCell('Dinheiro', 2),
                BuildHeaderCell('Valor', 1),
              ],
            ),
          ),
          ...payments.map((payment) => PaymentTile(payment: payment)),
        ],
      ],
    );
  }
}
