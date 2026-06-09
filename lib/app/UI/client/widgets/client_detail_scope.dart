import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:flutter/material.dart';

class ClientDetailsScope extends InheritedWidget {
  const ClientDetailsScope({
    super.key,
    required this.client,
    required super.child,
  });

  final ClientModel client;

  static ClientModel clientOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ClientDetailsScope>()!
        .client;
  }

  @override
  bool updateShouldNotify(ClientDetailsScope oldWidget) {
    return client != oldWidget.client;
  }
}
