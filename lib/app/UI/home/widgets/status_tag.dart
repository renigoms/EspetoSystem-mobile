import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:flutter/material.dart';

class StatusTag extends StatelessWidget {
  const StatusTag({super.key, required this.client});

  final ClientModel client;

  @override
  Widget build(BuildContext context) {
    // For now, returning an empty container until Account status logic is implemented
    return const SizedBox.shrink();
  }
}
