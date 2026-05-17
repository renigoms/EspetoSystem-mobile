import 'package:espetosystem/app/UI/home/messages/message_screen.dart';
import 'package:flutter/material.dart';

class FilterBarCustom extends StatelessWidget {
  final ThemeData theme;

  const FilterBarCustom({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          spacing: 7,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(filterLabelList.length, (index) {
            return Expanded(
              child: Container(
                width: double.infinity,
                height: 25,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimaryContainer,
                  border: Border.all(color: theme.colorScheme.onSecondary),
                  borderRadius: BorderRadius.circular(38),
                ),
                alignment: Alignment.center,
                child: Text(
                  filterLabelList[index],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
