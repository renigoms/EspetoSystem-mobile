import 'package:espetosystem/app/UI/authentication/views/login_page.dart';
import 'package:go_router/go_router.dart';

final authRoutes = [
  GoRoute(path: '/', builder: (context, state) => const LoginPage()),
];
