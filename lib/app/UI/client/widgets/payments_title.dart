import 'package:espetosystem/app/UI/home/widgets/custom_showcase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PaymentsTitle extends StatelessWidget {
  const PaymentsTitle({super.key, required this.onAdd, this.onHelpTap, this.addPaymentKey});

  final VoidCallback onAdd;
  final VoidCallback? onHelpTap;
  final GlobalKey? addPaymentKey;

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
        if (onHelpTap != null) ...[
          IconButton(
            onPressed: onHelpTap,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: Icon(
              Icons.help_outline,
              color: actionColor,
              size: 20,
            ),
          ),
        ],
        if (addPaymentKey != null)
          CustomShowcase(
            showcaseKey: addPaymentKey!,
            title: 'Adicionar Pagamento',
            description: 'Clique aqui para registrar um novo pagamento recebido deste cliente.',
            child: _buildAddButton(actionColor),
          )
        else
          _buildAddButton(actionColor),
      ],
    );
  }

  Widget _buildAddButton(Color actionColor) {
    return TextButton.icon(
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
    );
  }
}
