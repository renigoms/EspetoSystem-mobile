import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:espetosystem/app/UI/authentication/widgets/continue_enter_button.dart';
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

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

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
          ElevatedContinueEnterButton(
            theme: widget.theme,
            emailController: _emailController,
            passwordController: _passwordController,
          ),

          LabelOr(theme: widget.theme),
          EnterWithGoogle(theme: widget.theme),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
