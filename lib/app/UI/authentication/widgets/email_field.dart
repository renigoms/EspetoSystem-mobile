import 'package:espetosystem/app/UI/authentication/components/form_filed_decorate.dart';
import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:flutter/material.dart';

class EmailFormField extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController controller;
  const EmailFormField({
    super.key,
    required this.theme,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Row(
          children: [
            Text(
              MessageScreen.emailLabel.value,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          cursorColor: theme.colorScheme.onSurface,
          decoration: formFieldDecoration(theme, null),
        ),
      ],
    );
  }
}
