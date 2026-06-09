import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:espetosystem/app/data/repositories/auth_repository.dart';
import 'package:espetosystem/app/data/repositories/account_repository.dart';
import 'package:espetosystem/app/data/repositories/client_repository.dart';
import 'package:espetosystem/app/data/repositories/item_repository.dart';
import 'package:espetosystem/app/data/repositories/item_account_repository.dart';
import 'package:espetosystem/app/data/repositories/payment_repository.dart';
import 'package:espetosystem/app/data/services/local_cache_service.dart';
import 'package:espetosystem/app/data/services/network_info.dart';
import 'package:espetosystem/app/data/services/supabase_service.dart';
import 'package:espetosystem/app/my_app.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização do Supabase
  await Supabase.initialize(
    url: 'https://ccdrjqtyepypmwhdillk.supabase.co',
    anonKey: 'sb_secret_6Kz6OGV8dTcoQRygqpzfug_5yMZmsCb',
  );

  // Inicialização do SharedPreferences
  final sharedPrefs = await SharedPreferences.getInstance();

  // Instanciação de Serviços
  final supabaseClient = Supabase.instance.client;
  final supabaseService = SupabaseService(supabaseClient);
  final LocalCacheService localCacheService = LocalCacheService(sharedPrefs);
  final networkInfo = NetworkInfoImpl(Connectivity());

  // Inicialização do Google Sign In
  const webClientId =
      '823631587645-ed0pe3ukr3qrga348d40spjjidi8s7lp.apps.googleusercontent.com';

  await GoogleSignIn.instance.initialize(serverClientId: webClientId);
  final googleSignIn = GoogleSignIn.instance;

  // Instanciação de Repositórios
  final authRepository = AuthRepository(
    supabaseClient: supabaseClient,
    googleSignIn: googleSignIn,
    localCache: localCacheService,
  );

  final accountRepository = AccountRepository(
    remoteDataSource: supabaseService,
    localDataSource: localCacheService,
    networkInfo: networkInfo,
  );

  final clientRepository = ClientRepository(
    remoteDataSource: supabaseService,
    localDataSource: localCacheService,
    networkInfo: networkInfo,
    accountRepository: accountRepository,
  );

  final itemRepository = ItemRepository(
    remoteDataSource: supabaseService,
    localDataSource: localCacheService,
    networkInfo: networkInfo,
  );

  final itemAccountRepository = ItemAccountRepository(
    remoteDataSource: supabaseService,
    localDataSource: localCacheService,
    networkInfo: networkInfo,
  );

  final paymentRepository = PaymentRepository(
    remoteDataSource: supabaseService,
    localDataSource: localCacheService,
    networkInfo: networkInfo,
  );

  runApp(
    MyApp(
      authRepository: authRepository,
      accountRepository: accountRepository,
      clientRepository: clientRepository,
      itemRepository: itemRepository,
      itemAccountRepository: itemAccountRepository,
      paymentRepository: paymentRepository,
    ),
  );
}
