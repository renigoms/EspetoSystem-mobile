import 'package:espetosystem/app/UI/authentication/views/auth_screen.dart';
import 'package:go_router/go_router.dart';

final authRoutes = [
  GoRoute(path: '/', builder: (context, state) => AuthScreen()),
];
