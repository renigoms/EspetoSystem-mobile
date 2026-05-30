import 'package:espetosystem/app/UI/home/widgets/user_profile_avatar.dart';
import 'package:espetosystem/app/core/widgets/elevated_button_custom.dart';
import 'package:espetosystem/app/core/widgets/password_field.dart';
import 'package:espetosystem/app/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  Color _withAlpha(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round().clamp(0, 255));
  }

  String? _avatarUrl(User? user) {
    final metadata = user?.userMetadata;
    final rawUrl =
        metadata?['avatar_url'] ??
        metadata?['picture'] ??
        metadata?['photo_url'] ??
        metadata?['avatar'] ??
        metadata?['image_url'];

    if (rawUrl is String && rawUrl.isNotEmpty) {
      return rawUrl;
    }

    return null;
  }

  String _displayName(User? user) {
    final metadata = user?.userMetadata;
    final value =
        (metadata?['full_name'] ??
                metadata?['name'] ??
                user?.email ??
                'Usuário')
            .toString()
            .trim();

    return value.isEmpty ? 'Usuário' : value;
  }

  String _fallbackLabel(String displayName) {
    final parts =
        displayName
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .toList();
    if (parts.isEmpty) {
      return 'U';
    }

    final first = parts.first;
    final last = parts.length > 1 ? parts.last : '';
    final initials = '${first[0]}${last.isNotEmpty ? last[0] : ''}';
    return initials.toUpperCase();
  }

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthRepository>().signOut();
    if (!context.mounted) {
      return;
    }
    context.go('/');
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
                // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 500),
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
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: theme.colorScheme.primary,
                    //       minimumSize: const Size.fromHeight(44),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //     ),
                    //     onPressed:
                    //         loading
                    //             ? null
                    //             : () async {
                    //               final old = oldController.text.trim();
                    //               final nw = newController.text.trim();
                    //               final conf = confirmController.text.trim();
                    //               if (nw.isEmpty ||
                    //                   conf.isEmpty ||
                    //                   old.isEmpty) {
                    //                 ScaffoldMessenger.of(context).showSnackBar(
                    //                   const SnackBar(
                    //                     content: Text(
                    //                       'Preencha todos os campos',
                    //                     ),
                    //                   ),
                    //                 );
                    //                 return;
                    //               }
                    //               if (nw != conf) {
                    //                 ScaffoldMessenger.of(context).showSnackBar(
                    //                   const SnackBar(
                    //                     content: Text(
                    //                       'As senhas não coincidem',
                    //                     ),
                    //                   ),
                    //                 );
                    //                 return;
                    //               }
                    //               setState(() => loading = true);
                    //               try {
                    //                 final signIn = await authRepository
                    //                     .signInWithEmail(email, old);
                    //                 if (signIn.user == null) {
                    //                   ScaffoldMessenger.of(
                    //                     context,
                    //                   ).showSnackBar(
                    //                     const SnackBar(
                    //                       content: Text(
                    //                         'Senha antiga incorreta',
                    //                       ),
                    //                     ),
                    //                   );
                    //                   setState(() => loading = false);
                    //                   return;
                    //                 }
                    //                 await authRepository.updatePassword(nw);
                    //                 if (context.mounted) {
                    //                   ScaffoldMessenger.of(
                    //                     context,
                    //                   ).showSnackBar(
                    //                     const SnackBar(
                    //                       content: Text(
                    //                         'Senha atualizada com sucesso',
                    //                       ),
                    //                     ),
                    //                   );
                    //                   Navigator.of(ctx).pop();
                    //                 }
                    //               } catch (e) {
                    //                 if (context.mounted) {
                    //                   ScaffoldMessenger.of(
                    //                     context,
                    //                   ).showSnackBar(
                    //                     SnackBar(
                    //                       content: Text(
                    //                         'Erro ao atualizar: $e',
                    //                       ),
                    //                     ),
                    //                   );
                    //                 }
                    //               } finally {
                    //                 setState(() => loading = false);
                    //               }
                    //             },
                    //     child:
                    //         loading
                    //             ? const SizedBox(
                    //               width: 16,
                    //               height: 16,
                    //               child: CircularProgressIndicator(
                    //                 strokeWidth: 2,
                    //                 color: Colors.white,
                    //               ),
                    //             )
                    //             : Text(
                    //               'Salvar Alterações',
                    //               style: theme.textTheme.labelLarge?.copyWith(
                    //                 color: theme.colorScheme.onPrimary,
                    //               ),
                    //             ),
                    //   ),
                    // ),
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
    final displayName = _displayName(currentUser);
    final email = currentUser?.email ?? 'Sem e-mail cadastrado';
    final fallbackLabel = _fallbackLabel(displayName);

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
                  UserProfileAvatar(
                    size: 88,
                    avatarUrl: _avatarUrl(currentUser),
                    fallbackLabel: fallbackLabel,
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
                          iconBg: _withAlpha(theme.colorScheme.tertiary, 0.12),
                          iconColor: theme.colorScheme.tertiary,
                          title: 'Alterar dados pessoais',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Edição de dados pessoais em breve.',
                                ),
                              ),
                            );
                          },
                        ),
                        _StyledTile(
                          theme: theme,
                          icon: Icons.lock_outline,
                          iconBg: _withAlpha(theme.colorScheme.tertiary, 0.12),
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
                      iconBg: _withAlpha(theme.colorScheme.error, 0.08),
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
        top: BorderSide(width: 1, color: theme.colorScheme.onSecondary),
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
