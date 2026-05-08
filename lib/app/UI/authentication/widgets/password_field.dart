import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/UI/authentication/components/form_filed_decorate.dart';
import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordFormField extends StatelessWidget {
  final TextEditingController controller;
  final ThemeData theme;
  const PasswordFormField({
    super.key,
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final visible = Provider.of<AuthViewModel>(context).isVisible;
    return Column(
      children: [
        Column(
          spacing: 16,
          children: [
            Row(
              children: [
                Text(
                  MessageScreen.passwordLabel.value,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            TextFormField(
              controller: controller,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              obscureText: visible,
              decoration: formFieldDecoration(
                theme,
                InkWell(
                  onTap:
                      () =>
                          Provider.of<AuthViewModel>(
                            context,
                            listen: false,
                          ).setVisible(),
                  child: Icon(
                    color: theme.colorScheme.onSurface,
                    visible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              cursorColor: theme.colorScheme.onSurface,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                MessageScreen.forgotPassword.value,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
