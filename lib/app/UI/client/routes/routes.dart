import 'package:espetosystem/app/UI/client/view/adicionar_itens_screen.dart';
import 'package:espetosystem/app/UI/client/view/client_details_page.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _clientPurchasesNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'clientPurchases',
);
final _clientPaymentsNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'clientPayments',
);

final clientRoutes = [
  GoRoute(
    path: '/home/client/add-item',
    builder: (context, state) => const AdicionarItensScreen(),
  ),
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      final client = state.extra as ClientModel?;
      return ClientDetailsShellPage(
        navigationShell: navigationShell,
        client: client,
      );
    },
    branches: [
      StatefulShellBranch(
        navigatorKey: _clientPurchasesNavigatorKey,
        routes: [
          GoRoute(
            path: '/home/client',
            builder: (context, state) => const ClientDetailsPage(),
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: _clientPaymentsNavigatorKey,
        routes: [
          GoRoute(
            path: '/home/client/payments',
            builder: (context, state) => const ClientPaymentsPage(),
          ),
        ],
      ),
    ],
  ),
];
