import 'package:espetosystem/app/UI/client/view_model/client_view_model.dart';
import 'package:espetosystem/app/UI/client/widgets/client_detail_scope.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DebtSummaryCard extends StatelessWidget {
  const DebtSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final client = ClientDetailsScope.clientOf(context);
    final viewModel = context.watch<ClientViewModel>();

    final double totalDebt = viewModel.getTotalDebtForClient(client.id ?? '');
    final String formattedDebt =
        'R\$ ${totalDebt.toStringAsFixed(2).replaceAll('.', ',')}';

    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Falta Pagar',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 14,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedDebt,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 14,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
