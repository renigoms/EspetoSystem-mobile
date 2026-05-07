import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EnterWithGoogle extends StatelessWidget {
  final ThemeData theme;
  const EnterWithGoogle({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 7,
      children: [
        SvgPicture.asset("assets/icons/devicon_google.svg"),
        TextButton(
          onPressed: () {},
          child: Text(
            "Continue com o Google",
            style: theme.textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
