import 'package:espetosystem/app/core/themes/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppBarCustom extends StatelessWidget {
  final ThemeData theme;
  const AppBarCustom({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeViewModel>().themeMode;
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
          GestureDetector(
            onTap: () => context.push('/home/settings'),
            child: SvgPicture.asset(
              themeMode == ThemeMode.light
                  ? 'assets/icons/settings-light.svg'
                  : 'assets/icons/settings-dark.svg',
            ),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.primary,
    );
  }
}
