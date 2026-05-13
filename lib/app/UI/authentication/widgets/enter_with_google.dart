import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EnterWithGoogle extends StatelessWidget {
  final ThemeData theme;
  final Function onPressed;
  const EnterWithGoogle({
    super.key,
    required this.theme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 7,
      children: [
        SvgPicture.asset(ImagePathEnum.iconGoogle.value),
        TextButton(
          onPressed: () => onPressed(),
          child: Text(
            MessageScreen.continueWithGoogle.value,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
