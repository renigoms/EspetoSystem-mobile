// ignore_for_file: must_be_immutable

import 'package:espetosystem/app/UI/authentication/components/form_filed_decorate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DefaultFormField extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController controller;
  final String name;
  final String? hintText;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<dynamic>? inputFormatters;
  TextStyle? labelStyle;
  final FormFieldValidator<String>? validate;
  final AutovalidateMode? autoValidateMode;

  DefaultFormField({
    super.key,
    required this.name,
    required this.controller,
    required this.theme,
    this.hintText,
    this.maxLines,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.validate,
    this.autoValidateMode,
    TextStyle? labelStyle,
  }) : labelStyle = labelStyle ?? theme.textTheme.titleMedium;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      children: [
        Row(children: [Text(name, style: labelStyle)]),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters?.cast<TextInputFormatter>(),
          validator: validate,
          maxLength: maxLength,
          autovalidateMode:
              autoValidateMode ?? AutovalidateMode.onUserInteraction,
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
