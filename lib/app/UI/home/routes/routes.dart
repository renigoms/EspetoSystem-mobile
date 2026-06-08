import 'package:espetosystem/app/UI/home/view/client_search_screen.dart';
import 'package:espetosystem/app/UI/home/view/main_screen.dart';
import 'package:espetosystem/app/UI/home/view/personal_info_screen.dart';
import 'package:espetosystem/app/UI/home/view/settings_screan.dart';
import 'package:go_router/go_router.dart';

final homeRoutes = [
  GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
  GoRoute(
    path: '/home/personal-info',
    builder: (context, state) => const PersonalInfoScreen(),
  ),
  GoRoute(
    path: '/home/settings',
    builder: (context, state) => const SettingsScrean(),
  ),
  GoRoute(
    path: '/home/search',
    builder: (context, state) {
      final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
      return ClientSearchPage(
        clients: extra['clients'],
        initialQuery: extra['initialQuery'],
      );
    },
  ),
];
