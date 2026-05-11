import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:flutter/material.dart';

class FpSuccessPage extends StatelessWidget {
  final ThemeData theme;
  const FpSuccessPage({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 70),
        child: Center(
          child: Column(
            spacing: 38,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(ImagePathEnum.avatarForgotPass.value),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    MessageScreen.emailVerifyLabel.value,
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      MessageScreen.emailSendMsg.value,
                      softWrap: true,
                      textAlign: TextAlign.justify,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
