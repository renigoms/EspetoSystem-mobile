import 'package:espetosystem/app/UI/client/view_model/client_account_view_model.dart';
import 'package:espetosystem/app/UI/client/widgets/client_detail_scope.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class DebtSummaryCard extends StatelessWidget {
  const DebtSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final client = ClientDetailsScope.clientOf(context);
    final viewModel = context.watch<ClientAccountViewModel>();

    final items = viewModel.getItemsForClient(client.id ?? '');
    
    // Se não houver itens adicionados, não exibe o card (quadrado)
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final double totalDebt = viewModel.getTotalDebtForClient(client.id ?? '');
    final bool isPaid = totalDebt <= 0;

    final String formattedDebt =
        'R\$ ${totalDebt.toStringAsFixed(2).replaceAll('.', ',')}';

    return Column(
      children: [
        Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isPaid ? theme.colorScheme.tertiary : theme.colorScheme.error,
            borderRadius: BorderRadius.circular(6),
          ),
          child: isPaid
              ? Text(
                  'CONTA PAGA',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 15, // Unificando tamanho da fonte
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Falta Pagar',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 15, // Unificando tamanho da fonte
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDebt,
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 15, // Unificando tamanho da fonte
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
        if (isPaid) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => viewModel.clearAccount(client.id ?? ''),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: theme.colorScheme.tertiary.withValues(alpha: 0.1),
              foregroundColor: theme.colorScheme.tertiary,
            ),
            icon: const Icon(LucideIcons.rotateCcw, size: 16),
            label: Text(
              'Limpar Conta',
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
