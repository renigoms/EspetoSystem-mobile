import 'package:espetosystem/app/UI/home/view/main_screen.dart';
import 'package:espetosystem/app/UI/home/view/settings_screan.dart';
import 'package:go_router/go_router.dart';

final homeRoutes = [
  GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
  GoRoute(
    path: '/home/settings',
    builder: (context, state) => const SettingsScrean(),
  ),
];
