import 'package:espetosystem/app/authentication/pages/login_page.dart';
import 'package:espetosystem/app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "EspetoSystem",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: AppColorsEnum.darkColorTheme),
      home: LoginPage(),
    );
  }
}
