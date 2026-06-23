import 'package:espetosystem/app/UI/client/view_model/client_account_view_model.dart';
import 'package:espetosystem/app/UI/client/widgets/client_detail_scope.dart';
import 'package:espetosystem/app/data/models/purchased_item_model.dart';
import 'package:espetosystem/app/core/widgets/default_form_field.dart';
import 'package:espetosystem/app/core/widgets/elevated_button_custom.dart';
import 'package:espetosystem/app/UI/client/components/currency_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class PurchasedItemTile extends StatelessWidget {
  final PurchasedItemModel item;
  const PurchasedItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.74);

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

    return Dismissible(
      key: Key(item.id ?? '${item.description}_${item.quantity}_${item.value}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _showEditDialog(context);
          return false; // Sempre retorna false para o edit para o item voltar ao lugar após fechar o modal
        } else {
          return await _showDeleteDialog(context);
        }
      },
      background: Container(
        color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(LucideIcons.edit, color: theme.colorScheme.tertiary),
      ),
      secondaryBackground: Container(
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
                '${item.quantity}',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  color: mutedTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Text(
                item.unit,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  color: mutedTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Text(
                item.description,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Text(
                item.value,
                textAlign: TextAlign.center,
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
                totalFormatted,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
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
    final clientId = ClientDetailsScope.clientOf(context).id;
    final clientAccountViewModel = context.read<ClientAccountViewModel>();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            title: Text('Excluir Item', style: theme.textTheme.titleLarge),
            content: Text(
              'Deseja realmente excluir "${item.description}"?',
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

    if (result == true && clientId != null && item.id != null) {
      clientAccountViewModel.deleteItem(clientId, item.id!);
      return true;
    }
    return false;
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final descController = TextEditingController(text: item.description);
    final qtdController = TextEditingController(text: item.quantity.toString());
    final valorController = TextEditingController(text: item.value);
    final unitController = TextEditingController(text: item.unit);

    final clientId = ClientDetailsScope.clientOf(context).id;
    final clientAccountViewModel = context.read<ClientAccountViewModel>();

    await showDialog(
      context: context,
      builder:
          (ctx) => Center(
            child: SingleChildScrollView(
              child: Dialog(
                backgroundColor: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Editar Item', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 24),
                      DefaultFormField(
                        name: 'Quantidade',
                        controller: qtdController,
                        theme: theme,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      DefaultFormField(
                        name: 'Unidade',
                        controller: unitController,
                        theme: theme,
                        hintText: 'Ex: UND, KG...',
                      ),
                      const SizedBox(height: 16),
                      DefaultFormField(
                        name: 'Descrição',
                        controller: descController,
                        theme: theme,
                       ),
                      const SizedBox(height: 16),
                      DefaultFormField(
                        name: 'Valor Unitário',
                        controller: valorController,
                        theme: theme,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ElevatedButtomCustom(
                        theme: theme,
                        title: 'Salvar Alterações',
                        onPressed: () {
                          final String desc = descController.text.trim();
                          final String unit = unitController.text.trim();
                          final String rawValue = valorController.text
                              .replaceAll('R\$ ', '')
                              .replaceAll('.', '')
                              .replaceAll(',', '.');
                          final double valor = double.tryParse(rawValue) ?? 0;
                          final int qtd = int.tryParse(qtdController.text) ?? 0;

                          if (desc.isNotEmpty && unit.isNotEmpty && qtd > 0 && valor > 0) {
                            if (clientId != null && item.id != null) {
                              clientAccountViewModel.updateItem(
                                clientId,
                                item.id!,
                                desc,
                                qtd,
                                valor,
                                unit,
                              );
                            }
                            Navigator.pop(ctx);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
