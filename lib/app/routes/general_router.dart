import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:espetosystem/app/UI/authentication/routes/routes.dart';
import 'package:espetosystem/app/UI/home/routes/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final routes = GoRouter(
  initialLocation: '/',
  refreshListenable: null, // Será configurado via builder se necessário, ou deixamos estático se o provider não for acessível aqui.
  // Como o GoRouter é uma variável global, vamos usar uma estratégia diferente:
  // O redirect vai rodar em cada navegação.
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final bool loggingIn = state.matchedLocation == '/';

    if (session != null) {
      if (loggingIn) return '/home';
    } else {
      // Se não estiver logado e tentar acessar algo diferente de / ou recuperação de senha, volta pro login
      if (!loggingIn && 
          state.matchedLocation != '/forgotPassword' && 
          state.matchedLocation != '/update-password') {
        return '/';
      }
    }
    return null;
  },
  routes: [...authRoutes, ...homeRoutes],
);
