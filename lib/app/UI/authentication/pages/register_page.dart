import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:espetosystem/app/UI/authentication/widgets/default_form_field.dart';
import 'package:espetosystem/app/UI/authentication/widgets/elevated_button_custom.dart';
import 'package:espetosystem/app/UI/authentication/widgets/email_field.dart';
import 'package:espetosystem/app/UI/authentication/widgets/password_field.dart';
import 'package:espetosystem/app/UI/authentication/widgets/security_password_validate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final authViewModelRead = context.read<AuthViewModel>();
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
            spacing: 8,
            children: [
              PasswordFormField(
                name: MessageScreen.passwordLabel.value,
                controller: _passwordRegisterController,
                theme: widget.theme,
                onChanged: (value) {
                  authViewModelRead.setHasMinLength(value);
                  authViewModelRead.setHasNumberCase(value);
                  authViewModelRead.setHasSpecialCase(value);
                  authViewModelRead.setHasUpperCase(value);
                },
              ),
              _passwordRegisterController.text.isEmpty
                  ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          MessageScreen.messagePassRequired.value,
                          softWrap: true,
                          style: widget.theme.textTheme.labelSmall?.copyWith(
                            color: widget.theme.colorScheme.onTertiary,
                          ),
                        ),
                      ),
                    ],
                  )
                  : SecurityPasswordValidate(theme: widget.theme),
            ],
          ),
          PasswordFormField(
            name: MessageScreen.confirmPasswordLabel.value,
            controller: _confirmPasswordRegisterController,
            theme: widget.theme,
          ),

          ElevatedButtomCustom(
            theme: widget.theme,
            title: MessageScreen.buttonRegisterName.value,
            onPressed: () {
              final value = _passwordRegisterController.text;
              if (authViewModelRead.passwordFailVerify) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Essa senha está fraca !")),
                );
                return;
              }
              if (value != _confirmPasswordRegisterController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("As senhas não combinam")),
                );
              }
            },
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
