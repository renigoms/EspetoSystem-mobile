import 'package:espetosystem/app/UI/authentication/components/form_filed_decorate.dart';
import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordFormField extends StatefulWidget {
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
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _visible = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Row(
          children: [
            Text(widget.name, style: widget.theme.textTheme.titleMedium),
          ],
        ),
        TextFormField(
          controller: widget.controller,
          style: widget.theme.textTheme.labelSmall?.copyWith(
            color: widget.theme.colorScheme.onSurface,
          ),
          obscureText: _visible,
          decoration: formFieldDecoration(
            widget.theme,
            InkWell(
              onTap: () => setState(() => _visible = !_visible),
              child: Icon(
                color: widget.theme.colorScheme.onSurface,
                _visible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
          cursorColor: widget.theme.colorScheme.onSurface,
        ),
      ],
    );
  }
}
