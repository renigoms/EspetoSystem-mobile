import 'package:flutter/material.dart';

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

class BuildItemCard extends StatelessWidget {
  final ThemeData theme;
  final int index;
  final Map<String, dynamic> item;
  final void Function()? action;
  const BuildItemCard({
    super.key,
    required this.theme,
    required this.index,
    required this.item,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
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
                onTap: action,
                child: Icon(
                  Icons.delete,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dados do Card em Colunas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: _buildCardDataColumn(
                  'Qtd.',
                  item["quantidade"].toString(),
                  theme,
                ),
              ),
              Expanded(
                flex: 1,
                child: _buildCardDataColumn(
                  'Unid.',
                  item["unidade"].toString(),
                  theme,
                ),
              ),
              Expanded(
                flex: 2,
                child: _buildCardDataColumn(
                  'Descrição',
                  item["descricao"],
                  theme,
                ),
              ),
              Expanded(
                flex: 2,
                child: _buildCardDataColumn('V. Unit.', item["valor"], theme),
              ),
              Expanded(
                flex: 2,
                child: _buildCardDataColumn(
                  'Total',
                  item["total"] ?? '',
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
