import 'package:espetosystem/app/core/themes/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class AparenceButton extends StatelessWidget {
  const AparenceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          elevation: 0,
          builder:
              (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return Consumer<ThemeViewModel>(
                    builder: (context, themeViewModel, child) {
                      final currentTheme = Theme.of(context);

                      // A bolinha agora segue o tema real do app!
                      final int selectedIndex = themeViewModel.themeIndex();

                      final listRadiosOptions = [
                        {
                          "title": "Tema Claro",
                          "icon": LucideIcons.sun,
                          "theme": currentTheme.colorScheme.error,
                        },
                        {
                          "title": "Tema Escuro",
                          "icon": LucideIcons.moon,
                          "theme": currentTheme.colorScheme.tertiary,
                        },
                        {
                          "title": "Tema do sistema",
                          "icon": "assets/icons/system_theme.svg",
                          "theme": currentTheme.colorScheme.onSurface,
                        },
                      ];

                      return Container(
                        decoration: BoxDecoration(
                          color: currentTheme.colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        height: 280,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Column(
                            children: List.generate(listRadiosOptions.length, (
                              index,
                            ) {
                              final value = listRadiosOptions[index];
                              return RadioListTile(
                                value: index,
                                groupValue:
                                    selectedIndex, // Usa o estado global
                                hoverColor: currentTheme.colorScheme.tertiary,
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                fillColor: WidgetStatePropertyAll(
                                  currentTheme.colorScheme.tertiary,
                                ),
                                secondary:
                                    value["icon"].toString().contains(".svg") &&
                                            value['icon'] is String
                                        ? SvgPicture.asset(
                                          value['icon'].toString(),
                                          colorFilter: ColorFilter.mode(
                                            value['theme'] as Color,
                                            BlendMode.srcIn,
                                          ),
                                        )
                                        : Icon(
                                          value['icon'] as IconData?,
                                          color: value['theme'] as Color,
                                          size: 30,
                                        ),
                                onChanged: (value) {
                                  if (value == null) return;

                                  switch (value) {
                                    case 0:
                                      themeViewModel.setThemeMode(
                                        ThemeMode.light,
                                      );
                                      break;
                                    case 1:
                                      themeViewModel.setThemeMode(
                                        ThemeMode.dark,
                                      );
                                      break;
                                    case 2:
                                      themeViewModel.setThemeMode(
                                        ThemeMode.system,
                                      );
                                      break;
                                  }
                                },
                                title: Text(
                                  value["title"].toString(),
                                  style: currentTheme.textTheme.titleMedium,
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.onTertiary,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            spacing: 11,
            children: [
              SvgPicture.asset(
                'assets/icons/Icon-Set.svg',
                width: 20,
                height: 20,
              ),
              Text("Aparência", style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
