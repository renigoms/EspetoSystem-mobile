import 'package:espetosystem/app/UI/home/view/main_screen.dart';
import 'package:espetosystem/app/UI/client/view/client_details_page.dart';
import 'package:espetosystem/app/UI/home/view/personal_info_screen.dart';
import 'package:espetosystem/app/UI/home/view/settings_screan.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:go_router/go_router.dart';

final homeRoutes = [
  GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
  GoRoute(
    path: '/home/client',
    builder: (context, state) {
      final client = state.extra as ClientModel?;
      return ClientDetailsPage(client: client);
    },
  ),
  GoRoute(
    path: '/home/personal-info',
    builder: (context, state) => const PersonalInfoScreen(),
  ),
  GoRoute(
    path: '/home/settings',
    builder: (context, state) => const SettingsScrean(),
  ),
];
