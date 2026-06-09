import 'package:espetosystem/app/UI/client/widgets/setting_client_widget.dart';
import 'package:espetosystem/app/UI/home/widgets/client_form_sheet.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:flutter/material.dart';

Future<String?> actionModal(BuildContext context, ThemeData theme) async =>
    await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        return SettingClientWidget(theme: theme);
      },
    );

Future<ClientModel?> resultModal(
  BuildContext context,
  ClientModel client,
) async => await showModalBottomSheet<ClientModel>(
  context: context,
  isScrollControlled: true,
  useRootNavigator: true,
  builder: (context) => ClientFormSheet(client: client),
);
