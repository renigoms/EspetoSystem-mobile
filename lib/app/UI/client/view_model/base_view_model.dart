import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:espetosystem/app/data/models/purchased_item_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BaseViewModel extends ChangeNotifier {
  final SupabaseClient supabaseClient;
  final List<ClientModel> clients = <ClientModel>[];
  final Map<String, String> accountStatuses = <String, String>{};
  final Map<String, List<PurchasedItemModel>> clientItems =
      <String, List<PurchasedItemModel>>{};
  final Map<String, List<PaymentModel>> clientPayments =
      <String, List<PaymentModel>>{};

  bool isLoading = false;

  BaseViewModel(this.supabaseClient);
}
