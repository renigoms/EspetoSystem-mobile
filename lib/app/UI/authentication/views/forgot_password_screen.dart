import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/UI/authentication/pages/fp_input_page.dart';
import 'package:espetosystem/app/UI/authentication/pages/fp_success_page.dart';
import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:espetosystem/app/core/themes/text_theme.dart';
import 'package:espetosystem/app/core/themes/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isPassRecovery =
        context.watch<AuthViewModel>().passwordRecoverySuccess;
    final theme = Theme.of(context);
    final themeMode = context.watch<ThemeViewModel>().themeMode;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          MessageScreen.forgotPassword.value,
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: theme.colorScheme.secondary,
        shape: Border(
          bottom: BorderSide(
            width: 1.5,
            color:
                themeMode == ThemeMode.light
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.primaryContainer,
          ),
        ),
      ),
      backgroundColor: theme.colorScheme.secondary,
      body:
          isPassRecovery
              ? FpSuccessPage(theme: theme)
              : FgInputPage(theme: theme),
    );
  }
}
