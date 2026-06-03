import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:espetosystem/app/UI/home/view_models/home_view_model.dart';
import 'package:espetosystem/app/core/themes/color_theme.dart';
import 'package:espetosystem/app/core/themes/text_theme.dart';
import 'package:espetosystem/app/core/themes/theme_view_model.dart';
import 'package:espetosystem/app/routes/general_router.dart';
import 'package:espetosystem/app/data/repositories/item_repository.dart';
import 'package:espetosystem/app/data/repositories/item_account_repository.dart';
import 'package:espetosystem/app/data/repositories/payment_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:espetosystem/app/data/repositories/auth_repository.dart';
import 'package:espetosystem/app/data/repositories/account_repository.dart';
import 'package:espetosystem/app/data/repositories/client_repository.dart';

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final AccountRepository accountRepository;
  final ClientRepository clientRepository;
  final ItemRepository itemRepository;
  final ItemAccountRepository itemAccountRepository;
  final PaymentRepository paymentRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.accountRepository,
    required this.clientRepository,
    required this.itemRepository,
    required this.itemAccountRepository,
    required this.paymentRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: authRepository),
        Provider.value(value: accountRepository),
        Provider.value(value: clientRepository),
        Provider.value(value: itemRepository),
        Provider.value(value: itemAccountRepository),
        Provider.value(value: paymentRepository),
        ChangeNotifierProvider(
          create:
              (_) =>
                  AuthViewModel(authRepository: authRepository)
                    ..onPasswordRecovery = (route) {
                      routes.push(route);
                    },
        ),
        ChangeNotifierProvider(
          create:
              (_) => HomeViewModel(
                accountRepository: accountRepository,
                clientRepository: clientRepository,
                itemRepository: itemRepository,
                itemAccountRepository: itemAccountRepository,
                paymentRepository: paymentRepository,
                supabaseClient: authRepository.supabaseClient,
              ),
        ),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer2<ThemeViewModel, AuthViewModel>(
        builder: (context, themeViewModel, authViewModel, _) {
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
