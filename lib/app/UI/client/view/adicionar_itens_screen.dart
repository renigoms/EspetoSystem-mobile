import 'dart:ui';
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

  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _unidadeController = TextEditingController(text: 'UND');
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
    final qtdText = _quantidadeController.text;
    final unidade = _unidadeController.text;
    final valorText = _valorController.text;
    final desc = _descricaoController.text;

    if (qtdText.isNotEmpty && desc.isNotEmpty && valorText.isNotEmpty) {
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
      _unidadeController.text = 'UND';
      _descricaoController.clear();
      _valorController.clear();
    }
  }

  double get _totalGeral =>
      itensAdicionados.fold(0, (sum, item) => sum + (item['totalValue'] as double));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
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
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: DefaultFormField(
                    name: 'Unidade',
                    controller: _unidadeController,
                    theme: theme,
                    hintText: 'Ex: UND, KG...',
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
            ),
            const SizedBox(height: 24),
            
            // Botão Adicionar Item (Texto Azul com Borda Tracejada)
            GestureDetector(
              onTap: _adicionarItem,
              child: CustomPaint(
                painter: DashedRectPainter(color: theme.colorScheme.tertiary),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: theme.colorScheme.tertiary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Adicionar Item',
                        style: TextStyle(
                          color: theme.colorScheme.tertiary, 
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Botão Concluir (Fundo Azul)
            ElevatedButtomCustom(
              theme: theme,
              title: 'Concluir',
              onPressed: () {
                Navigator.of(context).pop(itensAdicionados);
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
                shrinkWrap: true, // Necessário por estar dentro do SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: itensAdicionados.length,
                itemBuilder: (context, index) {
                  final item = itensAdicionados[index];
                  return _buildItemCard(item, index, theme);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildItemCard(Map<String, dynamic> item, int index, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.onSecondary.withValues(alpha: 0.16),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do Card (Nome do item e botão de excluir)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'item ${index + 1}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    itensAdicionados.removeAt(index);
                  });
                },
                child: Icon(
                  Icons.delete,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          
          // Dados do Card em Colunas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: _buildCardDataColumn('Qtd.', item["quantidade"].toString(), theme),
              ),
              Expanded(
                flex: 1,
                child: _buildCardDataColumn('Unid.', item["unidade"].toString(), theme),
              ),
              Expanded(
                flex: 2,
                child: _buildCardDataColumn('Descrição', item["descricao"], theme),
              ),
              Expanded(
                flex: 2,
                child: _buildCardDataColumn('V. Unit.', item["valor"], theme),
              ),
              Expanded(
                flex: 2,
                child: _buildCardDataColumn('Total', item["total"] ?? '', theme),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCardDataColumn(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text);
    final formatter = 'R\$ ${(value / 100).toStringAsFixed(2).replaceAll('.', ',')}';

    return newValue.copyWith(
        text: formatter,
        selection: TextSelection.collapsed(offset: formatter.length));
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = Colors.blue,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(4),
    ));

    Path dashedPath = Path();
    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
