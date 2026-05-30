import 'package:espetosystem/app/UI/home/widgets/aparence_button.dart';
import 'package:espetosystem/app/UI/home/widgets/label_title.dart';
import 'package:espetosystem/app/UI/home/widgets/system_infor_bar.dart';
import 'package:flutter/material.dart';

class SettingsScrean extends StatelessWidget {
  const SettingsScrean({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
        // centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        toolbarHeight: 74,
        iconTheme: IconThemeData(color: theme.colorScheme.tertiary, size: 35),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          child: Column(
            spacing: 50,
            children: [
              Column(
                spacing: 20,
                children: [
                  LabelTitle(theme: theme, title: "Preferências"),
                  Column(
                    children: [
                      AparenceButton(),
                      // Se der tempo, implementar a o botão para a janela de acensibilidade
                    ],
                  ),
                ],
              ),
              Column(
                spacing: 20,
                children: [
                  LabelTitle(theme: theme, title: "Sobre"),
                  SystemInforBar(theme: theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
