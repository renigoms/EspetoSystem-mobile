import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppBarCustom extends StatelessWidget {
  final ThemeData theme;
  const AppBarCustom({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 75,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 17,
            children: [
              Image.asset('assets/images/logo.png', width: 31, height: 41),
              Row(
                children: [
                  Text(
                    "Espeto",
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  Text(
                    "System",
                    style: TextStyle(color: theme.colorScheme.tertiary),
                  ),
                ],
              ),
            ],
          ),
          SvgPicture.asset('assets/icons/settings.svg'),
        ],
      ),
      backgroundColor: theme.colorScheme.primary,
    );
  }
}
