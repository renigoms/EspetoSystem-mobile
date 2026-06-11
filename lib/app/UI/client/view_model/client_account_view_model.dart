import 'package:espetosystem/app/UI/client/view_model/base_view_model.dart';
import 'package:espetosystem/app/core/components/view_model_components.dart';
import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:espetosystem/app/data/models/purchased_item_model.dart';
import 'package:espetosystem/app/data/services/client_account_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientAccountViewModel extends BaseViewModel {
  final ClientAccountService _service;
  final SupabaseClient _supabaseClient;

  ClientAccountViewModel(this._service, this._supabaseClient) : super(_supabaseClient);

  List<PurchasedItemModel> getItemsForClient(String clientId) => clientItems[clientId] ?? [];
  List<PaymentModel> getPaymentsForClient(String clientId) => clientPayments[clientId] ?? [];
  double getTotalDebtForClient(String clientId) => totalDebtForClient(clientId, clientItems, clientPayments);

  Future<void> loadItemsForClient(String clientId, {bool force = false}) async {
    if (!force && clientItems.containsKey(clientId) && clientItems[clientId]!.isNotEmpty) return;

    try {
      final account = await _service.accountRepository.getByClientId(clientId);
      if (account?.id == null) {
        clientItems[clientId] = [];
        notifyListeners();
        return;
      }

      clientItems[clientId] = await _service.loadItems(account!.id!);
      clientPayments[clientId] = await _service.loadPayments(account.id!);
      
      await _updateStatus(clientId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading items/payments: $e');
    }
  }

  Future<void> addPaymentToClientAccount(String clientId, Map<String, dynamic> paymentData) async {
    final userId = currentUserId(_supabaseClient);
    if (userId == null) return;

    try {
      final account = await _service.accountRepository.getByClientId(clientId);
      if (account?.id == null) return;

      final double valor = paymentData['valor'] as double;
      final payment = await _service.savePayment(account!.id!, valor, userId);

      if (payment != null) {
        clientPayments[clientId] = [...(clientPayments[clientId] ?? []), payment];
      } else {
        // Fallback offline
        clientPayments[clientId] = [...(clientPayments[clientId] ?? []), PaymentModel(accountId: account.id!, date: DateTime.now(), value: valor)];
      }

      await _updateStatus(clientId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding payment: $e');
    }
  }

  Future<void> addItemsToClientAccount(String clientId, List<Map<String, dynamic>> items) async {
    final userId = currentUserId(_supabaseClient);
    if (userId == null) return;

    try {
      final account = await _service.getOrCreateAccount(clientId, userId);
      if (account?.id == null) return;

      final List<PurchasedItemModel> newPurchasedItems = [];

      for (final itemData in items) {
        final description = itemData['descricao'].toString();
        final quantity = int.tryParse(itemData['quantidade'].toString()) ?? 0;
        final unit = itemData['unidade']?.toString() ?? 'UND';
        final double unitValue = double.tryParse(itemData['valor'].toString().replaceAll('R\$ ', '').replaceAll('.', '').replaceAll(',', '.')) ?? 0;

        final item = await _service.getOrCreateItem(description, unit, userId);
        
        if (item.id != null) {
          await _service.linkItemToAccount(item.id!, account!.id!, quantity, unitValue, userId);
        }

        newPurchasedItems.add(PurchasedItemModel(
          quantity: quantity,
          unit: unit,
          description: description,
          value: itemData['valor'].toString(),
        ));
      }

      clientItems[clientId] = [...(clientItems[clientId] ?? []), ...newPurchasedItems];
      accountStatuses[clientId] = 'DEVENDO';
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding items: $e');
    }
  }

  Future<void> deleteItem(String clientId, String itemAccountId) async {
    final userId = currentUserId(_supabaseClient);
    if (userId == null) return;

    try {
      await _service.deleteItemAccount(itemAccountId, userId);
      
      // Remove da lista local
      if (clientItems.containsKey(clientId)) {
        clientItems[clientId] = clientItems[clientId]!
            .where((item) => item.id != itemAccountId)
            .toList();
      }
      
      await _updateStatus(clientId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  Future<void> deletePayment(String clientId, String paymentId) async {
    final userId = currentUserId(_supabaseClient);
    if (userId == null) return;

    try {
      await _service.deletePayment(paymentId, userId);

      // Remove da lista local
      if (clientPayments.containsKey(clientId)) {
        clientPayments[clientId] = clientPayments[clientId]!
            .where((p) => p.id != paymentId)
            .toList();
      }

      await _updateStatus(clientId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting payment: $e');
    }
  }

  Future<void> clearAccount(String clientId) async {
    final userId = currentUserId(_supabaseClient);
    if (userId == null) return;

    try {
      final account = await _service.accountRepository.getByClientId(clientId);
      if (account?.id != null) {
        await _service.clearAccount(account!.id!, userId);
        
        // Limpa localmente para forçar a criação de uma nova conta no próximo load/add
        clientItems.remove(clientId);
        clientPayments.remove(clientId);
        accountStatuses[clientId] = 'LIMPA';
        
        // Recarrega (vai criar uma nova conta se necessário)
        await loadItemsForClient(clientId, force: true);
      }
    } catch (e) {
      debugPrint('Error clearing account: $e');
    }
  }

  Future<void> updateItem(
    String clientId, 
    String itemAccountId, 
    String description,
    int quantity, 
    double unitValue
  ) async {
    final userId = currentUserId(_supabaseClient);
    if (userId == null) return;

    try {
      await _service.updateItemAccount(itemAccountId, description, quantity, unitValue, userId);
      
      // Recarrega os itens para garantir que a UI reflita os valores formatados corretamente
      // Ou podemos atualizar localmente se preferir performance
      final account = await _service.accountRepository.getByClientId(clientId);
      if (account?.id != null) {
        clientItems[clientId] = await _service.loadItems(account!.id!);
      }
      
      await _updateStatus(clientId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  Future<void> _updateStatus(String clientId) async {
    accountStatuses[clientId] = await getStatusIfNeeded(
      clientId,
      currentUserId(_supabaseClient),
      _service.accountRepository,
      getTotalDebtForClient(clientId),
    );
  }
}
