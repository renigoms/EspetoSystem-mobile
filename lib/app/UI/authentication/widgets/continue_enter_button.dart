import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ElevatedContinueEnterButton extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController passwordController;
  final TextEditingController emailController;
  const ElevatedContinueEnterButton({
    super.key,
    required this.theme,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    final AuthViewModel auth = Provider.of<AuthViewModel>(context);
    final showPasswordField = auth.showPasswordField;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          ),

          backgroundColor: WidgetStateProperty.all(theme.colorScheme.tertiary),
        ),
        onPressed: () {
          if (showPasswordField) {
            if (passwordController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Todos os campos devem ser preenchidos !"),
                ),
              );
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Login realizado com sucesso seguir para home"),
              ),
            );
            return;
          }
          if (emailController.text.isNotEmpty) {
            Provider.of<AuthViewModel>(
              context,
              listen: false,
            ).setShowPasswordField();
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Todos os campos devem ser preenchidos !")),
          );
        },
        child: Text(
          showPasswordField
              ? MessageScreen.enter.value
              : MessageScreen.continueLogin.value,
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}
