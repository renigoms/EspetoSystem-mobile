import 'package:espetosystem/app/UI/client/components/currency_input_formatter.dart';
import 'package:espetosystem/app/UI/client/widgets/build_item_card.dart';
import 'package:espetosystem/app/UI/client/widgets/dashed_buttom.dart';
import 'package:espetosystem/app/core/widgets/default_form_field.dart';
import 'package:espetosystem/app/core/widgets/elevated_button_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdicionarItensScreen extends StatefulWidget {
  const AdicionarItensScreen({super.key});

  @override
  State<AdicionarItensScreen> createState() => _AdicionarItensScreenState();
}

class _AdicionarItensScreenState extends State<AdicionarItensScreen> {
  // Lista que será populada dinamicamente
  final List<Map<String, dynamic>> itensAdicionados = [];
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _unidadeController = TextEditingController(
    text: 'UND',
  );
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  @override
  void dispose() {
    _quantidadeController.dispose();
    _unidadeController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _adicionarItem() {
    if (_formKey.currentState!.validate()) {
      final qtdText = _quantidadeController.text;
      final unidade = _unidadeController.text;
      final valorText = _valorController.text;
      final desc = _descricaoController.text;

      final double qtd = double.tryParse(qtdText) ?? 0;
      // Remove "R$ ", replace thousands separator (dots) and decimal separator (comma)
      final String numericValor = valorText
          .replaceAll('R\$ ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      final double valorUnitario = double.tryParse(numericValor) ?? 0;
      final double total = qtd * valorUnitario;

      setState(() {
        itensAdicionados.add({
          "id": itensAdicionados.length + 1,
          "quantidade": qtdText,
          "unidade": unidade,
          "descricao": desc,
          "valor": valorText,
          "total": 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
          "totalValue": total,
        });
      });
      _quantidadeController.clear();
      _descricaoController.clear();
      _valorController.clear();
      _formKey.currentState!.reset();
      _unidadeController.text = 'UND';
    }
  }

  double get _totalGeral => itensAdicionados.fold(
    0,
    (sum, item) => sum + (item['totalValue'] as double),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.tertiary),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Adicionar itens',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEÇÃO DO FORMULÁRIO ---
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    flex: 2,
                    child: DefaultFormField(
                      name: 'Quantidade',
                      controller: _quantidadeController,
                      theme: theme,
                      hintText: 'Ex: 1',
                      keyboardType: TextInputType.number,
                      validate: (value) => value == null || value.trim().isEmpty
                          ? 'Informe a quantidade'
                          : null,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: DefaultFormField(
                      name: 'Unidade',
                      controller: _unidadeController,
                      theme: theme,
                      hintText: 'Ex: UND, KG...',
                      validate: (value) => value == null || value.trim().isEmpty
                          ? 'Informe a unidade'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DefaultFormField(
                name: 'Descrição',
                controller: _descricaoController,
                theme: theme,
                hintText: 'produto, serviço...',
                maxLines: 4,
                validate: (value) => value == null || value.trim().isEmpty
                    ? 'Informe a descrição'
                    : null,
              ),
              const SizedBox(height: 16),

              DefaultFormField(
                name: 'Valor Unitário',
                controller: _valorController,
                theme: theme,
                hintText: 'R\$ 0,00',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                validate: (value) => value == null || value.trim().isEmpty
                    ? 'Informe o valor'
                    : null,
              ),
              const SizedBox(height: 24),

              // Botão Adicionar Item (Texto Azul com Borda Tracejada)
              DashedButtom(action: _adicionarItem, theme: theme),

              const SizedBox(height: 16),

              // Botão Concluir (Fundo Azul)
              ElevatedButtomCustom(
                theme: theme,
                title: 'Concluir',
                onPressed: () {
                  if (itensAdicionados.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Adicione um item'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    Navigator.of(context).pop(itensAdicionados);
                  }
                },
              ),

              const SizedBox(height: 32),

              // --- SEÇÃO DA LISTA ---
              if (itensAdicionados.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Itens Adicionados (${itensAdicionados.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total: R\$ ${_totalGeral.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Lista de Cards
                ListView.builder(
                  shrinkWrap:
                      true, // Necessário por estar dentro do SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itensAdicionados.length,
                  itemBuilder: (context, index) {
                    final item = itensAdicionados[index];
                    return BuildItemCard(
                      index: index,
                      item: item,
                      theme: theme,
                      action: () {
                        setState(() {
                          itensAdicionados.removeAt(index);
                        });
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
