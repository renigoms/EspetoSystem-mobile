import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/UI/authentication/widgets/default_form_field.dart';
import 'package:espetosystem/app/UI/authentication/widgets/email_field.dart';
import 'package:espetosystem/app/UI/authentication/widgets/password_field.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final ThemeData theme;
  final _emailRegisterController = TextEditingController();
  final _nameRegisterController = TextEditingController();
  final _passwordRegisterController = TextEditingController();
  final _confirmPasswordRegisterController = TextEditingController();

  RegisterPage({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 43),
      child: Column(
        spacing: 25,
        children: [
          DefaultFormField(
            name: MessageScreen.nameLabel.value,
            controller: _nameRegisterController,
            theme: theme,
          ),
          EmailFormField(theme: theme, controller: _emailRegisterController),
          Column(
            children: [
              PasswordFormField(
                name: MessageScreen.passwordLabel.value,
                controller: _passwordRegisterController,
                theme: theme,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Use 8+ caracteres distribuidos entre letras, números e especiais",
                      softWrap: true,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          PasswordFormField(
            name: MessageScreen.confirmPasswordLabel.value,
            controller: _confirmPasswordRegisterController,
            theme: theme,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(
                  theme.colorScheme.tertiary,
                ),
              ),
              child: Text(
                MessageScreen.buttonRegisterName.value,
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
