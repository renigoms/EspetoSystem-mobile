import 'package:espetosystem/app/UI/client/components/currency_input_formatter.dart';
import 'package:espetosystem/app/core/widgets/default_form_field.dart';
import 'package:espetosystem/app/core/widgets/elevated_button_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddPaymentDialog extends StatefulWidget {
  const AddPaymentDialog({super.key});

  @override
  State<AddPaymentDialog> createState() => AddPaymentDialogState();
}

class AddPaymentDialogState extends State<AddPaymentDialog> {
  final TextEditingController _valorController = TextEditingController();

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.secondary,
      insetPadding: const EdgeInsets.all(24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registrar Pagamento',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24.0),
            DefaultFormField(
              name: 'Valor do Pagamento',
              controller: _valorController,
              theme: theme,
              hintText: 'R\$ 0,00',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
            ),
            const SizedBox(height: 32.0),
            ElevatedButtomCustom(
              theme: theme,
              title: 'Confirmar Pagamento',
              onPressed: () {
                final valorText = _valorController.text;
                if (valorText.isNotEmpty) {
                  final String rawValue = valorText
                      .replaceAll('R\$ ', '')
                      .replaceAll('.', '')
                      .replaceAll(',', '.');
                  final double valor = double.tryParse(rawValue) ?? 0;

                  if (valor > 0) {
                    Navigator.of(
                      context,
                    ).pop({'valor': valor, 'metodo': 'Dinheiro'});
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
