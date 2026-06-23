import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:espetosystem/app/UI/home/components/image_manage.dart';
import 'package:espetosystem/app/UI/home/components/person_info_dialog_custom.dart';
import 'package:espetosystem/app/UI/home/extensions/string_extension.dart';
import 'package:espetosystem/app/UI/home/extensions/user_extension.dart';
import 'package:espetosystem/app/UI/home/widgets/styled_tile.dart';
import 'package:espetosystem/app/UI/home/widgets/user_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthViewModel>().signOut();
    if (!context.mounted) {
      return;
    }
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.read<AuthViewModel>();
    final currentUser = viewModel.currentUser;
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
                    onTap: () => updateProfilePhoto(context),
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          StyledTile(
                            theme: theme,
                            icon: Icons.info_outline,
                            iconBg: theme.colorScheme.tertiary.withValues(
                              alpha: 0.12,
                            ),
                            iconColor: theme.colorScheme.tertiary,
                            title: 'Alterar dados pessoais',
                            onTap:
                                () => showEditNameDialog(
                                  context,
                                  theme,
                                  displayName,
                                  () {
                                    setState(() {});
                                  },
                                ),
                          ),
                          StyledTile(
                            theme: theme,
                            icon: Icons.lock_outline,
                            iconBg: theme.colorScheme.tertiary.withValues(
                              alpha: 0.12,
                            ),
                            iconColor: theme.colorScheme.tertiary,
                            title: 'Alterar senha',
                            onTap:
                                () => showChangePasswordDialog(
                                  context,
                                  theme,
                                  email,
                                ),
                          ),
                        ],
                      ),

                      StyledTile(
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
            ),
          ],
        ),
      ),
    );
  }
}
