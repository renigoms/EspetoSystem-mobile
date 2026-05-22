import 'package:espetosystem/app/UI/authentication/components/button_style.dart';
import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:espetosystem/app/core/widgets/elevated_button_custom.dart';
import 'package:espetosystem/app/UI/authentication/widgets/email_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FgInputPage extends StatefulWidget {
  final ThemeData theme;
  const FgInputPage({super.key, required this.theme});

  @override
  State<FgInputPage> createState() => _FgInputPageState();
}

class _FgInputPageState extends State<FgInputPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    style: widget.theme.textTheme.titleMedium,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    MessageScreen.msgForgPassPageSubTitle.value,
                    textAlign: TextAlign.justify,
                    style: widget.theme.textTheme.labelSmall?.copyWith(
                      color: widget.theme.colorScheme.onTertiary,
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
                EmailFormField(
                  theme: widget.theme,
                  controller: _emailController,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButtomCustom(
                    theme: widget.theme,
                    title: MessageScreen.sendLabel.value,
                    onPressed:
                        () => setState(
                          () =>
                              context
                                  .read<AuthViewModel>()
                                  .setPassRecoverySucc(),
                        ),
                  ),
                  // ElevatedButton(
                  //   onPressed:
                  //       () => setState(
                  //         () =>
                  //             context
                  //                 .read<AuthViewModel>()
                  //                 .setPassRecoverySucc(),
                  //       ),
                  //   style: buttonStyleBlue(widget.theme),
                  //   child: Text(
                  //     MessageScreen.sendLabel.value,
                  //     style: widget.theme.textTheme.titleLarge,
                  //   ),
                  // ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
