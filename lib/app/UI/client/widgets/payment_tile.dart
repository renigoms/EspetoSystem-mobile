import 'package:espetosystem/app/UI/client/view_model/client_account_view_model.dart';
import 'package:espetosystem/app/UI/client/widgets/client_detail_scope.dart';
import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class PaymentTile extends StatelessWidget {
  final PaymentModel payment;
  const PaymentTile({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Formatação nativa de data sem depender do pacote intl
    final day = payment.date.day.toString().padLeft(2, '0');
    final month = payment.date.month.toString().padLeft(2, '0');
    final year = payment.date.year.toString();
    final String formattedDate = '$day/$month/$year';

    final String formattedValue =
        'R\$ ${payment.value.toStringAsFixed(2).replaceAll('.', ',')}';

    return Dismissible(
      key: Key(
        payment.id ??
            'payment_${payment.date.millisecondsSinceEpoch}_${payment.value}',
      ),
      direction:
          DismissDirection.endToStart, // Apenas da direita para a esquerda
      confirmDismiss: (direction) async {
        return await _showDeleteDialog(context);
      },
      // No Flutter, o 'background' é o widget principal para o deslize.
      // Como a direção é 'endToStart', o Flutter usará este background.
      background: Container(
        color: theme.colorScheme.error.withValues(alpha: 0.2),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(LucideIcons.trash2, color: theme.colorScheme.error),
      ),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.onSecondary.withValues(alpha: 0.16),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 0,
              child: Text(
                formattedDate,
                style: GoogleFonts.roboto(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Text(
                'Dinheiro', // Simulando método de pagamento pois PaymentModel não tem
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Text(
                formattedValue,
                style: GoogleFonts.roboto(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            title: Text('Excluir Pagamento', style: theme.textTheme.titleLarge),
            content: Text(
              'Deseja realmente excluir este pagamento?',
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Excluir',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
    );

    if (result == true && context.mounted) {
      final clientId = ClientDetailsScope.clientOf(context).id;
      if (clientId != null && payment.id != null) {
        context.read<ClientAccountViewModel>().deletePayment(
          clientId,
          payment.id!,
        );
        return true;
      }
    }
    return false;
  }
}
