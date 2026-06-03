import 'package:espetosystem/app/UI/authentication/components/form_filed_decorate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DefaultFormField extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController controller;
  final String name;
  final String? hintText;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<dynamic>? inputFormatters;

  const DefaultFormField({
    super.key,
    required this.name,
    required this.controller,
    required this.theme,
    this.hintText,
    this.maxLines,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Row(children: [Text(name, style: theme.textTheme.titleMedium)]),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters?.cast<TextInputFormatter>(),
          decoration: formFieldDecoration(theme, null).copyWith(
            hintText: hintText,
            hintStyle: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          cursorColor: theme.colorScheme.onSurface,
        ),
      ],
    );
  }
}
