import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavigationButtons extends StatelessWidget {
  final ThemeData theme;
  final bool isLogin;

  const NavigationButtons({
    super.key,
    required this.isLogin,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 40, right: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => {context.read<AuthViewModel>().setIsLogin(true)},
              child: Container(
                alignment: Alignment.center,
                height: 39,
                color:
                    isLogin
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onPrimary,
                child: Text(
                  MessageScreen.buttonLoginName.value,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => {context.read<AuthViewModel>().setIsLogin(false)},
              child: Container(
                alignment: Alignment.center,
                height: 39,
                color:
                    !isLogin
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onPrimary,
                child: Text(
                  MessageScreen.buttonRegisterName.value,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
