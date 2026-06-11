import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PaymentsTitle extends StatelessWidget {
  const PaymentsTitle({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionColor = theme.colorScheme.tertiary;

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
        TextButton.icon(
          onPressed: onAdd,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: Icon(
            LucideIcons.plus,
            color: actionColor,
            size: 16,
          ),
          label: Text(
            'Adicionar Pagamento',
            style: GoogleFonts.roboto(
              color: actionColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
