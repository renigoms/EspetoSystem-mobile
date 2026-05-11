import 'package:espetosystem/app/UI/authentication/messages/text_enum.dart';
import 'package:espetosystem/app/UI/authentication/views/auth_screen.dart';
import 'package:espetosystem/app/UI/authentication/views/forgot_password_screen.dart';
import 'package:go_router/go_router.dart';

final authRoutes = [
  GoRoute(path: '/', builder: (context, state) => AuthScreen()),
  GoRoute(
    path: RoutesPathEnum.forgotPassword.value,
    builder: (context, state) => ForgotPasswordScreen(),
  ),
];
