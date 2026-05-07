import 'package:espetosystem/app/UI/authentication/view_models/login_view_model.dart';
import 'package:espetosystem/app/core/themes/app_themes.dart';
import 'package:espetosystem/app/routes/general_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LoginModelViel())],
      child: MaterialApp.router(
        title: "EspetoSystem",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: darkColorTheme, textTheme: textTheme),
        routerDelegate: routes.routerDelegate,
        routeInformationParser: routes.routeInformationParser,
        routeInformationProvider: routes.routeInformationProvider,
      ),
    );
  }
}
