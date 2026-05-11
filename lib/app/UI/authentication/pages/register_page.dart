import 'package:espetosystem/app/UI/authentication/components/button_style.dart';
import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/UI/authentication/widgets/default_form_field.dart';
import 'package:espetosystem/app/UI/authentication/widgets/email_field.dart';
import 'package:espetosystem/app/UI/authentication/widgets/password_field.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final ThemeData theme;

  const RegisterPage({super.key, required this.theme});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailRegisterController = TextEditingController();

  final _nameRegisterController = TextEditingController();

  final _passwordRegisterController = TextEditingController();

  final _confirmPasswordRegisterController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailRegisterController.dispose();
    _confirmPasswordRegisterController.dispose();
    _nameRegisterController.dispose();
    _passwordRegisterController.dispose();
  }

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
            theme: widget.theme,
          ),
          EmailFormField(
            theme: widget.theme,
            controller: _emailRegisterController,
          ),
          Column(
            children: [
              PasswordFormField(
                name: MessageScreen.passwordLabel.value,
                controller: _passwordRegisterController,
                theme: widget.theme,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Use 8+ caracteres distribuidos entre letras, números e especiais",
                      softWrap: true,
                      style: widget.theme.textTheme.labelSmall?.copyWith(
                        color: widget.theme.colorScheme.onTertiary,
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
            theme: widget.theme,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: buttonStyleBlue(widget.theme),
              child: Text(
                MessageScreen.buttonRegisterName.value,
                style: widget.theme.textTheme.titleLarge,
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
