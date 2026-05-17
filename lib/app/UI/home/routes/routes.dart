import 'package:espetosystem/app/UI/home/view/main_screen.dart';
import 'package:go_router/go_router.dart';

final homeRoutes = [
  GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
];
