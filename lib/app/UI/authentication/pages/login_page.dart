// ignore_for_file: use_build_context_synchronously

import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:espetosystem/app/UI/authentication/widgets/elevated_button_custom.dart';
import 'package:espetosystem/app/UI/authentication/widgets/email_field.dart';
import 'package:espetosystem/app/UI/authentication/widgets/enter_with_google.dart';
import 'package:espetosystem/app/UI/authentication/widgets/label_or.dart';
import 'package:espetosystem/app/UI/authentication/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final ThemeData theme;

  const LoginPage({super.key, required this.theme});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  String? testeID;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void snackMessage(String message, BuildContext context) =>
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final AuthViewModel auth = context.watch<AuthViewModel>();
    final showPasswordField = auth.showPasswordField;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 43),
      child: Column(
        spacing: 18,
        children: [
          EmailFormField(theme: widget.theme, controller: _emailController),
          if (showPasswordField) ...[
            Column(
              children: [
                PasswordFormField(
                  controller: _passwordController,
                  theme: widget.theme,
                  name: MessageScreen.passwordLabel.value,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        context.read<AuthViewModel>().setPassRecoverySucc();
                        context.push(RoutesPathEnum.forgotPassword.value);
                      },
                      child: Text(
                        style: widget.theme.textTheme.labelSmall?.copyWith(
                          color: widget.theme.colorScheme.onSurface,
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
          ElevatedButtomCustom(
            theme: widget.theme,
            title:
                showPasswordField
                    ? MessageScreen.enter.value
                    : MessageScreen.continueLogin.value,
            onPressed: () {
              final action = context
                  .read<AuthViewModel>()
                  .handleLoginButtonPressed(
                    _emailController.text,
                    _passwordController.text,
                  );

              if (action is String) {
                snackMessage(action, context);
                return;
              }

              final email = _emailController.text,
                  password = _passwordController.text;

              if (action == true &&
                  email == "admin@admin.com" &&
                  password == "admin") {
                context.go('/home');
              }
            },
          ),

          LabelOr(theme: widget.theme),
          EnterWithGoogle(
            theme: widget.theme,
            onPressed: () async {
              String? idUSer =
                  await context
                      .read<AuthViewModel>()
                      .continueWithGoogleAction();

              if (!mounted) return;

              snackMessage(idUSer, context);
              context.go('/home');
            },
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
