import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:espetosystem/app/core/themes/color_theme.dart';

import 'package:espetosystem/app/core/themes/text_theme.dart';
import 'package:espetosystem/app/core/themes/theme_view_model.dart';
import 'package:espetosystem/app/routes/general_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp.router(
            title: "EspetoSystem",
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
              colorScheme: lightColorTheme,
              textTheme: textTheme,
            ),

            darkTheme: ThemeData(
              colorScheme: darkColorTheme,
              textTheme: textTheme,
            ),

            themeMode: themeViewModel.themeMode,

            routerDelegate: routes.routerDelegate,
            routeInformationParser: routes.routeInformationParser,
            routeInformationProvider: routes.routeInformationProvider,
          );
        },
      ),
    );
  }
}
