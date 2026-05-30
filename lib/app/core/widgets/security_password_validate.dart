import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:espetosystem/app/UI/authentication/widgets/check_password_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SecurityPasswordValidate extends StatelessWidget {
  final ThemeData theme;

  const SecurityPasswordValidate({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final authViewModelWatch = context.watch<AuthViewModel>();
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              CheckPasswordRow(
                text: "8+ caracteres",
                theme: theme,
                isValid: authViewModelWatch.hasMinLength,
              ),
              CheckPasswordRow(
                text: "1+ Letras Maiúsculas",
                theme: theme,
                isValid: authViewModelWatch.hasUpperCase,
              ),
              CheckPasswordRow(
                text: "1+ Números",
                theme: theme,
                isValid: authViewModelWatch.hasNumberCase,
              ),
              CheckPasswordRow(
                text: "1+ Caracteres Especiais",
                theme: theme,
                isValid: authViewModelWatch.hasSpecialCase,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
