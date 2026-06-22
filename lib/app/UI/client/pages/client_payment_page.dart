import 'package:espetosystem/app/UI/client/view_model/client_account_view_model.dart';
import 'package:espetosystem/app/core/widgets/custom_snack_bar.dart';
import 'package:espetosystem/app/UI/client/widgets/add_payment_dialog.dart';
import 'package:espetosystem/app/UI/client/widgets/build_header_cell.dart';
import 'package:espetosystem/app/UI/client/widgets/client_detail_scope.dart';
import 'package:espetosystem/app/UI/client/widgets/client_header.dart';
import 'package:espetosystem/app/UI/client/widgets/debt_summary_card.dart';
import 'package:espetosystem/app/UI/client/widgets/payment_tile.dart';
import 'package:espetosystem/app/UI/client/widgets/payments_title.dart';
import 'package:espetosystem/app/UI/home/widgets/custom_showcase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class ClientPaymentsPage extends StatefulWidget {
  const ClientPaymentsPage({super.key});

  @override
  State<ClientPaymentsPage> createState() => _ClientPaymentsPageState();
}

class _ClientPaymentsPageState extends State<ClientPaymentsPage> {
  final GlobalKey _debtCardKey = GlobalKey();
  final GlobalKey _addPaymentButtonKey = GlobalKey();
  final GlobalKey _firstPaymentKey = GlobalKey();
  bool _tutorialStarted = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final client = ClientDetailsScope.clientOf(context);
        if (client.id != null) {
          context.read<ClientAccountViewModel>().loadItemsForClient(
            client.id!,
          ); // This also loads payments
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = ClientDetailsScope.clientOf(context);
    final viewModel = context.watch<ClientAccountViewModel>();
    final payments = viewModel.getPaymentsForClient(client.id ?? '');

    return ShowCaseWidget(
      builder: (showcaseContext) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!viewModel.isLoading && !viewModel.hasSeenPaymentsOnboarding && !_tutorialStarted) {
            _tutorialStarted = true;
            final keys = [
              if (payments.isNotEmpty) _debtCardKey,
              _addPaymentButtonKey,
              if (payments.isNotEmpty) _firstPaymentKey,
            ];
            ShowCaseWidget.of(showcaseContext).startShowCase(keys);
            viewModel.completeClientPaymentsOnboarding();
          }
        });

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          children: [
            ClientHeader(client: client),
            const SizedBox(height: 22),
            if (payments.isNotEmpty)
              CustomShowcase(
                showcaseKey: _debtCardKey,
                title: 'Status da Conta',
                description: 'Veja se a conta deste cliente está PAGA ou se ainda há saldo pendente.',
                child: const DebtSummaryCard(),
              )
            else
              const DebtSummaryCard(),
            const SizedBox(height: 28),
            PaymentsTitle(
              addPaymentKey: _addPaymentButtonKey,
              onHelpTap: () {
                _tutorialStarted = true;
                final keys = [
                  if (payments.isNotEmpty) _debtCardKey,
                  _addPaymentButtonKey,
                  if (payments.isNotEmpty) _firstPaymentKey,
                ];
                ShowCaseWidget.of(showcaseContext).startShowCase(keys);
              },
              onAdd: () async {
                final totalDebt = viewModel.getTotalDebtForClient(client.id ?? '');
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) => AddPaymentDialog(totalDebt: totalDebt),
                );

                if (result != null && context.mounted) {
                  final viewModel = context.read<ClientAccountViewModel>();
                  if (client.id != null) {
                    await viewModel.addPaymentToClientAccount(client.id!, result);

                    if (context.mounted) {
                      CustomSnackBar.showSuccess(
                        context,
                        'Pagamento adicionado com sucesso!',
                      );
                    }
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BuildHeaderCell('Data'),
                    SizedBox(),
                    BuildHeaderCell('Forma de Pagamento'),
                    BuildHeaderCell('Valor'),
                  ],
                ),
              ),
              ...payments.asMap().entries.map((entry) {
                final index = entry.key;
                final payment = entry.value;
                final tile = PaymentTile(payment: payment);
                if (index == 0) {
                  return CustomShowcase(
                    showcaseKey: _firstPaymentKey,
                    title: 'Excluir Pagamento',
                    description: 'Deslize o pagamento para a esquerda para excluí-lo em caso de erro.',
                    child: tile,
                  );
                }
                return tile;
              }),
            ],
          ],
        );
      },
    );
  }
}
