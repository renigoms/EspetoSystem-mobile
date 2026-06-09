import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PaymentsTitle extends StatelessWidget {
  const PaymentsTitle({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Pagamentos',
            style: GoogleFonts.roboto(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: onAdd,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 28, height: 28),
          padding: EdgeInsets.zero,
          tooltip: 'Adicionar pagamento',
          icon: Icon(
            LucideIcons.badgeDollarSign,
            color: theme.colorScheme.onSurface,
            size: 19,
          ),
        ),
      ],
    );
  }
}
