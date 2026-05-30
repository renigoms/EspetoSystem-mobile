import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:espetosystem/app/core/widgets/elevated_button_custom.dart';
import 'package:espetosystem/app/core/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.read<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nova Senha"),
        backgroundColor: theme.colorScheme.secondary,
      ),
      backgroundColor: theme.colorScheme.secondary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            spacing: 20,
            children: [
              const Text(
                "Digite sua nova senha abaixo para recuperar o acesso.",
                textAlign: TextAlign.center,
              ),
              PasswordFormField(
                controller: _passwordController,
                theme: theme,
                name: "Nova Senha",
              ),
              PasswordFormField(
                controller: _confirmPasswordController,
                theme: theme,
                name: "Confirme a Nova Senha",
              ),
              const SizedBox(height: 20),
              ElevatedButtomCustom(
                theme: theme,
                title: "Atualizar Senha",
                onPressed: () async {
                  if (_passwordController.text !=
                      _confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("As senhas não coincidem!")),
                    );
                    return;
                  }
                  if (_passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("A senha não pode ser vazia!"),
                      ),
                    );
                    return;
                  }

                  final result = await authViewModel.updatePassword(
                    _passwordController.text,
                  );
                  if (result == "true") {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Senha atualizada com sucesso!"),
                        ),
                      );
                      context.go('/');
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Erro ao atualizar senha: $result"),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
