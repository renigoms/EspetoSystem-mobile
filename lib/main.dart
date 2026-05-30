import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:espetosystem/app/my_app.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/data/repositories/auth_repository.dart';
import 'app/data/repositories/client_repository.dart';
import 'app/data/services/local_cache_service.dart';
import 'app/data/services/network_info.dart';
import 'app/data/services/supabase_service.dart';

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
  final localCacheService = LocalCacheService(sharedPrefs);
  final networkInfo = NetworkInfoImpl(Connectivity());

  // Inicialização do Google Sign In
  // TODO: Substitua pelo seu Web Client ID real do Google Cloud Console
  const webClientId =
      '823631587645-ed0pe3ukr3qrga348d40spjjidi8s7lp.apps.googleusercontent.com';

  await GoogleSignIn.instance.initialize(serverClientId: webClientId);
  final googleSignIn = GoogleSignIn.instance;

  // Instanciação de Repositórios
  final authRepository = AuthRepository(
    supabaseClient: supabaseClient,
    googleSignIn: googleSignIn,
  );

  final clientRepository = ClientRepository(
    remoteDataSource: supabaseService,
    localDataSource: localCacheService,
    networkInfo: networkInfo,
  );

  runApp(
    MyApp(authRepository: authRepository, clientRepository: clientRepository),
  );
}
