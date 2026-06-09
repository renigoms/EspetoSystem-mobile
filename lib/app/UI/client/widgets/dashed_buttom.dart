import 'package:espetosystem/app/UI/client/components/dashed_rect_painter.dart';
import 'package:flutter/material.dart';

class DashedButtom extends StatelessWidget {
  final void Function()? action;
  final ThemeData theme;

  const DashedButtom({super.key, this.action, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
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
    );
  }
}
