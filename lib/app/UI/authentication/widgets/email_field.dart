import 'package:espetosystem/app/UI/authentication/components/form_filed_decorate.dart';
import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:flutter/material.dart';

class EmailFormField extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController controller;
  final String? Function(String?)? validate;
  const EmailFormField({
    super.key,
    required this.theme,
    required this.controller,
    this.validate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
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
          validator: validate,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
