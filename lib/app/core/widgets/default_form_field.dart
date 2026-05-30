import 'package:espetosystem/app/UI/authentication/components/form_filed_decorate.dart';
import 'package:flutter/material.dart';

class DefaultFormField extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController controller;
  final String name;
  const DefaultFormField({
    super.key,
    required this.name,
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Row(children: [Text(name, style: theme.textTheme.titleMedium)]),
        TextFormField(
          controller: controller,
          decoration: formFieldDecoration(theme, null),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          cursorColor: theme.colorScheme.onSurface,
        ),
      ],
    );
  }
}
