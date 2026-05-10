import 'package:espetosystem/app/UI/authentication/components/form_filed_decorate.dart';
import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordFormField extends StatelessWidget {
  final TextEditingController controller;
  final ThemeData theme;
  final String name;
  const PasswordFormField({
    super.key,
    required this.controller,
    required this.theme,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final visible = context.watch<AuthViewModel>().isVisible;
    return Column(
      spacing: 16,
      children: [
        Row(children: [Text(name, style: theme.textTheme.titleMedium)]),
        TextFormField(
          controller: controller,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          obscureText: visible,
          decoration: formFieldDecoration(
            theme,
            InkWell(
              onTap: () => context.read<AuthViewModel>().setVisible(),
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
    );
  }
}
