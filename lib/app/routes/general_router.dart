import 'package:espetosystem/app/UI/authentication/routes/routes.dart';
import 'package:go_router/go_router.dart';

final routes = GoRouter(initialLocation: '/', routes: [...authRoutes]);
