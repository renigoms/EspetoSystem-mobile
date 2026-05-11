import 'package:espetosystem/app/UI/authentication/components/button_style.dart';
import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/UI/authentication/widgets/email_field.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          MessageScreen.forgotPassword.value,
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: theme.colorScheme.secondary,
        shape: Border(
          bottom: BorderSide(
            width: 1.5,
            color: theme.colorScheme.primaryContainer,
          ),
        ),
      ),
      backgroundColor: theme.colorScheme.secondary,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 39),
        child: Column(
          spacing: 40,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      MessageScreen.msgForgPassPageTitle.value,
                      textAlign: TextAlign.justify,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      MessageScreen.msgForgPassPageSubTitle.value,
                      textAlign: TextAlign.justify,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  EmailFormField(theme: theme, controller: _emailController),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: buttonStyleBlue(theme),
                      child: Text(
                        MessageScreen.sendLabel.value,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
