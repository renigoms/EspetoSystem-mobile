import 'package:espetosystem/app/UI/home/widgets/edit_name_dialog.dart';
import 'package:espetosystem/app/core/widgets/elevated_button_custom.dart';
import 'package:espetosystem/app/core/widgets/password_field.dart';
import 'package:espetosystem/app/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

Future<void> showEditNameDialog(
  BuildContext context,
  ThemeData theme,
  AuthRepository authRepository,
  String currentName,
  VoidCallback onUpdate,
) async {
  await showDialog<void>(
    context: context,
    builder:
        (ctx) => EditNameDialog(
          currentName: currentName,
          onSave: (newName) async {
            try {
              await authRepository.updateProfile(name: newName);
              if (context.mounted) {
                onUpdate(); // Força rebuild para pegar novos metadados
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nome atualizado com sucesso')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao atualizar nome: $e')),
                );
              }
            }
          },
        ),
  );
}

Future<void> showChangePasswordDialog(
  BuildContext context,
  ThemeData theme,
  AuthRepository authRepository,
  String email,
) async {
  final oldController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Dialog(
            backgroundColor: theme.colorScheme.secondary,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                spacing: 20,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  PasswordFormField(
                    controller: oldController,
                    theme: theme,
                    name: "Senha Antiga",
                  ),
                  // Nova senha
                  PasswordFormField(
                    controller: newController,
                    theme: theme,
                    name: "Nova Senha",
                  ),
                  // Confirmar
                  PasswordFormField(
                    controller: confirmController,
                    theme: theme,
                    name: 'Confirme sua senha',
                  ),
                  ElevatedButtomCustom(
                    theme: theme,
                    title: "Salvar alterações",
                    onPressed: () async {
                      final old = oldController.text.trim();
                      final nw = newController.text.trim();
                      final conf = confirmController.text.trim();
                      if (nw.isEmpty || conf.isEmpty || old.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Preencha todos os campos'),
                          ),
                        );
                        return;
                      }
                      if (nw != conf) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('As senhas não coincidem'),
                          ),
                        );
                        return;
                      }
                      try {
                        final signIn = await authRepository.signInWithEmail(
                          email,
                          old,
                        );
                        if (signIn.user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Senha antiga incorreta'),
                            ),
                          );
                          return;
                        }
                        await authRepository.updatePassword(nw);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Senha atualizada com sucesso'),
                            ),
                          );
                          Navigator.of(ctx).pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao atualizar: $e')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
