import 'package:espetosystem/app/UI/home/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserAddPlusCustom extends StatelessWidget {
  final ThemeData theme;
  const UserAddPlusCustom({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 31,
      height: 31,
      decoration: decorationContainerCustom(theme),
      child: SvgPicture.asset(
        'assets/icons/user-plus.svg',
        colorFilter: ColorFilter.mode(
          theme.colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
