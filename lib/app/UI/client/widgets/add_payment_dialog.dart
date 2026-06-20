import 'package:espetosystem/app/UI/client/components/currency_input_formatter.dart';
import 'package:espetosystem/app/core/widgets/default_form_field.dart';
import 'package:espetosystem/app/core/widgets/elevated_button_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddPaymentDialog extends StatefulWidget {
  final double totalDebt;
  const AddPaymentDialog({super.key, required this.totalDebt});

  @override
  State<AddPaymentDialog> createState() => AddPaymentDialogState();
}

class AddPaymentDialogState extends State<AddPaymentDialog> {
  final TextEditingController _valorController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrar Pagamento',
                style: theme.textTheme.titleLarge?.copyWith(
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
                validate: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe um valor';
                  }
                  final String rawValue = value
                      .replaceAll('R\$ ', '')
                      .replaceAll('.', '')
                      .replaceAll(',', '.');
                  final double valor = double.tryParse(rawValue) ?? 0;
                  if (valor <= 0) {
                    return 'Informe um valor maior que zero';
                  }
                  if (valor > widget.totalDebt) {
                    final formattedLimit =
                        'R\$ ${widget.totalDebt.toStringAsFixed(2).replaceAll('.', ',')}';
                    return 'O valor máximo permitido é $formattedLimit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButtomCustom(
                theme: theme,
                title: 'Confirmar Pagamento',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final valorText = _valorController.text;
                    final String rawValue = valorText
                        .replaceAll('R\$ ', '')
                        .replaceAll('.', '')
                        .replaceAll(',', '.');
                    final double valor = double.tryParse(rawValue) ?? 0;

                    Navigator.of(
                      context,
                    ).pop({'valor': valor, 'metodo': 'Dinheiro'});
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
