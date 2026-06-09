import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return Container(
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
        children: [
          Expanded(
            flex: 1,
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
            flex: 2,
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
            flex: 1,
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
    );
  }
}
