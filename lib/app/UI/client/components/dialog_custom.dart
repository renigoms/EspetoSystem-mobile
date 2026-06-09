import 'package:espetosystem/app/UI/client/widgets/confirm_dialog_widget.dart';
import 'package:flutter/material.dart';

Future<bool?> confirmDialog(BuildContext context, ThemeData theme) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialogWidget(theme: theme),
    );
