import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/UI/authentication/components/form_filed_decorate.dart';
import 'package:flutter/material.dart';

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
              decoration: formFieldDecoration(theme),
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
