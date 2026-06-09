import 'package:espetosystem/app/data/models/purchased_item_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PurchasedItemTile extends StatelessWidget {
  final PurchasedItemModel item;
  const PurchasedItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.74);

    // Calcula o total (Qtd * V. Unit)
    final double unitValue =
        double.tryParse(
          item.value
              .replaceAll('R\$ ', '')
              .replaceAll('.', '')
              .replaceAll(',', '.'),
        ) ??
        0;
    final double total = item.quantity * unitValue;
    final String totalFormatted =
        'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';

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
          // Qtd
          Expanded(
            flex: 1,
            child: Text(
              '${item.quantity}',
              style: GoogleFonts.roboto(
                color: mutedTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Unid
          Expanded(
            flex: 1,
            child: Text(
              item.unit,
              style: GoogleFonts.roboto(
                color: mutedTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Descrição
          Expanded(
            flex: 2,
            child: Text(
              item.description,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // V. Unit.
          Expanded(
            flex: 2,
            child: Text(
              item.value,
              style: GoogleFonts.roboto(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Total
          Expanded(
            flex: 2,
            child: Text(
              totalFormatted,
              style: GoogleFonts.roboto(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
