import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:espetosystem/app/UI/authentication/widgets/continue_enter_button.dart';
import 'package:espetosystem/app/UI/authentication/widgets/email_field.dart';
import 'package:espetosystem/app/UI/authentication/widgets/enter_with_google.dart';
import 'package:espetosystem/app/UI/authentication/widgets/label_or.dart';
import 'package:espetosystem/app/UI/authentication/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final ThemeData theme;

  const LoginPage({
    super.key,
    required this.theme,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    final AuthViewModel auth = context.watch<AuthViewModel>();
    final showPasswordField = auth.showPasswordField;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 43),
      child: Column(
        spacing: 18,
        children: [
          EmailFormField(theme: theme, controller: emailController),
          if (showPasswordField) ...[
            Column(
              children: [
                PasswordFormField(
                  controller: passwordController,
                  theme: theme,
                  name: MessageScreen.passwordLabel.value,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        MessageScreen.forgotPassword.value,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          ElevatedContinueEnterButton(
            theme: theme,
            emailController: emailController,
            passwordController: passwordController,
          ),

          LabelOr(theme: theme),
          EnterWithGoogle(theme: theme),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
