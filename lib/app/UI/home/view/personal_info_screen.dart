import 'package:espetosystem/app/UI/home/extensions/string_extension.dart';
import 'package:espetosystem/app/UI/home/extensions/user_extension.dart';
import 'package:espetosystem/app/UI/home/widgets/user_profile_avatar.dart';
import 'package:espetosystem/app/core/widgets/default_form_field.dart';
import 'package:espetosystem/app/core/widgets/elevated_button_custom.dart';
import 'package:espetosystem/app/core/widgets/password_field.dart';
import 'package:espetosystem/app/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthRepository>().signOut();
    if (!context.mounted) {
      return;
    }
    context.go('/');
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    ThemeData theme,
    AuthRepository authRepository,
    String currentName,
  ) async {
    await showDialog<void>(
      context: context,
      builder:
          (ctx) => EditNameDialog(
            currentName: currentName,
            onSave: (newName) async {
              try {
                await authRepository.updateProfile(name: newName);
                if (mounted) {
                  setState(() {}); // Força rebuild para pegar novos metadados
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nome atualizado com sucesso'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao atualizar nome: $e')),
                  );
                }
              }
            },
          ),
    );
  }

  Future<void> _updateProfilePhoto(
    BuildContext context,
    AuthRepository authRepository,
  ) async {
    final ImagePicker picker = ImagePicker();
    try {
      // 1. Seleciona a imagem da galeria
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512, // Limita o tamanho para performance
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        // Nota: Para um app de produção, você faria o upload da imagem
        // para o Supabase Storage aqui e obteria a URL pública.
        // Como estamos focados na lógica de metadados agora,
        // vamos simular o salvamento de uma URL ou path.

        // TODO: Implementar upload para Supabase Storage se necessário.
        // Por enquanto, atualizamos apenas se tivéssemos a URL.

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Funcionalidade de upload de foto em desenvolvimento.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao selecionar foto: $e')));
      }
    }
  }

  Future<void> _showChangePasswordDialog(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authRepository = context.read<AuthRepository>();
    final currentUser = authRepository.supabaseClient.auth.currentUser;
    final displayName = currentUser?.displayName;
    final email = currentUser?.email ?? 'Sem e-mail cadastrado';
    final fallbackLabel = displayName!.fallbackLabel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações pessoais'),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.tertiary, size: 30),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          spacing: 20,
          children: [
            Container(
              width: double.infinity,
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.only(top: 18, bottom: 22),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _updateProfilePhoto(context, authRepository),
                    child: UserProfileAvatar(
                      size: 88,
                      avatarUrl: currentUser?.avatarUrl,
                      fallbackLabel: fallbackLabel,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        _StyledTile(
                          theme: theme,
                          icon: Icons.info_outline,
                          iconBg: theme.colorScheme.tertiary.withValues(
                            alpha: 0.12,
                          ),
                          iconColor: theme.colorScheme.tertiary,
                          title: 'Alterar dados pessoais',
                          onTap:
                              () => _showEditNameDialog(
                                context,
                                theme,
                                authRepository,
                                displayName,
                              ),
                        ),
                        _StyledTile(
                          theme: theme,
                          icon: Icons.lock_outline,
                          iconBg: theme.colorScheme.tertiary.withValues(
                            alpha: 0.12,
                          ),
                          iconColor: theme.colorScheme.tertiary,
                          title: 'Alterar senha',
                          onTap:
                              () => _showChangePasswordDialog(
                                context,
                                theme,
                                authRepository,
                                email,
                              ),
                        ),
                      ],
                    ),

                    _StyledTile(
                      theme: theme,
                      icon: Icons.logout,
                      iconBg: theme.colorScheme.error.withValues(alpha: 0.08),
                      iconColor: theme.colorScheme.error,
                      title: 'Sair da sessão',
                      trailing: Icon(
                        Icons.close,
                        color: theme.colorScheme.error,
                      ),
                      onTap: () => _signOut(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditNameDialog extends StatefulWidget {
  final String currentName;
  final Function(String) onSave;

  const EditNameDialog({
    super.key,
    required this.currentName,
    required this.onSave,
  });

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.secondary,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 24.0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultFormField(
              name: 'Nome',
              controller: _nameController,
              theme: theme,
              hintText: 'Seu nome completo',
            ),
            const SizedBox(height: 32.0),
            ElevatedButtomCustom(
              theme: theme,
              title: 'Salvar Alterações',
              onPressed: () {
                widget.onSave(_nameController.text.trim());
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StyledTile extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _StyledTile({
    required this.theme,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: Border(
        top: BorderSide(width: 0.5, color: theme.colorScheme.onTertiary),
      ),
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              trailing ??
                  Icon(Icons.chevron_right, color: theme.colorScheme.tertiary),
            ],
          ),
        ),
      ),
    );
  }
}
