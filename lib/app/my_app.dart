import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:espetosystem/app/UI/client/view_model/client_view_model.dart';
import 'package:espetosystem/app/UI/client/view_model/client_account_view_model.dart';
import 'package:espetosystem/app/UI/home/view_models/home_view_model.dart';
import 'package:espetosystem/app/core/themes/color_theme.dart';
import 'package:espetosystem/app/core/themes/text_theme.dart';
import 'package:espetosystem/app/core/themes/theme_view_model.dart';
import 'package:espetosystem/app/routes/general_router.dart';
import 'package:espetosystem/app/data/repositories/item_repository.dart';
import 'package:espetosystem/app/data/repositories/item_account_repository.dart';
import 'package:espetosystem/app/data/repositories/payment_repository.dart';
import 'package:espetosystem/app/data/services/client_account_service.dart';
import 'package:espetosystem/app/data/services/local_cache_service.dart';
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
  final LocalCacheService localCacheService;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.accountRepository,
    required this.clientRepository,
    required this.itemRepository,
    required this.itemAccountRepository,
    required this.paymentRepository,
    required this.localCacheService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: authRepository)
            ..onPasswordRecovery = (route) {
              routes.push(route);
            },
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(
            accountRepository: accountRepository,
            clientRepository: clientRepository,
            itemAccountRepository: itemAccountRepository,
            paymentRepository: paymentRepository,
            itemRepository: itemRepository,
            supabaseClient: authRepository.supabaseClient,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeViewModel(localCacheService),
        ),
        ChangeNotifierProvider(
          create: (_) => ClientViewModel(
            clientRepository,
            authRepository.supabaseClient,
          ),
        ),
        ProxyProvider0<ClientAccountService>(
          update: (_, __) => ClientAccountService(
            accountRepository: accountRepository,
            itemRepository: itemRepository,
            itemAccountRepository: itemAccountRepository,
            paymentRepository: paymentRepository,
          ),
        ),
        ChangeNotifierProxyProvider<ClientAccountService, ClientAccountViewModel>(
          create: (context) => ClientAccountViewModel(
            context.read<ClientAccountService>(),
            authRepository.supabaseClient,
          ),
          update: (context, service, previous) =>
              previous ?? ClientAccountViewModel(service, authRepository.supabaseClient),
        ),
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
