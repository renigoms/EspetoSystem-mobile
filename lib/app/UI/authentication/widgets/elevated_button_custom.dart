import 'package:espetosystem/app/UI/authentication/components/button_style.dart';
import 'package:flutter/material.dart';

class ElevatedButtomCustom extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final Function onPressed;
  const ElevatedButtomCustom({
    super.key,
    required this.theme,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: buttonStyleBlue(theme),
        onPressed: () => onPressed(),
        child: Text(title, style: theme.textTheme.displaySmall),
      ),
    );
  }
}
