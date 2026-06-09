import 'package:espetosystem/app/UI/home/messages/message_screen.dart';
import 'package:flutter/material.dart';

class FilterBarCustom extends StatelessWidget {
  final ThemeData theme;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const FilterBarCustom({
    super.key,
    required this.theme,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filterLabelList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final bool selected = selectedIndex == index;

          return InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(38),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 78,
              height: 28,
              decoration: BoxDecoration(
                color:
                    selected
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.primary,
                border: Border.all(
                  color:
                      selected
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.onSecondary.withValues(
                            alpha: 0.55,
                          ),
                ),
                borderRadius: BorderRadius.circular(38),
              ),
              alignment: Alignment.center,
              child: Text(
                filterLabelList[index],
                style: theme.textTheme.labelSmall?.copyWith(
                  color:
                      selected ? Colors.white : theme.colorScheme.onSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
