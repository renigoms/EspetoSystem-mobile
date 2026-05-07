import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/core/colors/app_colors.dart';
import 'package:flutter/material.dart';

class TitleContainer extends StatelessWidget {
  final ThemeData theme;

  const TitleContainer({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surface,
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 70, right: 70),
      child: Column(
        spacing: 15,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            ImagePathEnum.logoImagePath.value,
            width: 125,
            height: 129,
          ),
          Column(
            spacing: 5,
            children: [
              Text(
                MessageScreen.title.value,
                style: theme.textTheme.titleLarge,
              ),
              Text(
                MessageScreen.subtitle.value,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
