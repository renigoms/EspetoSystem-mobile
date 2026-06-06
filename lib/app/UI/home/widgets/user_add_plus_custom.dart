import 'package:espetosystem/app/UI/home/components/decorations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserAddPlusCustom extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onTap;

  const UserAddPlusCustom({
    super.key,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 31,
        height: 31,
        child: DecoratedBox(
          decoration: decorationContainerCustom(theme),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/user-plus.svg',
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
