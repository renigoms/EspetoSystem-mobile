import 'package:espetosystem/app/UI/client/view_model/base_view_model.dart';
import 'package:espetosystem/app/UI/home/view_models/home_view_model.dart';
import 'package:espetosystem/app/core/components/view_model_components.dart';
import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:espetosystem/app/data/models/purchased_item_model.dart';
import 'package:espetosystem/app/data/models/item_model.dart';
import 'package:espetosystem/app/data/models/account_model.dart';
import 'package:espetosystem/app/data/services/client_account_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientAccountViewModel extends BaseViewModel {
  final ClientAccountService _service;
  final SupabaseClient _supabaseClient;
  final HomeViewModel? _homeViewModel;

  ClientAccountViewModel(
    this._service,
    this._supabaseClient, {
    HomeViewModel? homeViewModel,
  }) : _homeViewModel = homeViewModel,
       super(_supabaseClient);

  List<PurchasedItemModel> getItemsForClient(String clientId) =>
      clientItems[clientId] ?? [];
  List<PaymentModel> getPaymentsForClient(String clientId) =>
      clientPayments[clientId] ?? [];
  double getTotalDebtForClient(String clientId) =>
      totalDebtForClient(clientId, clientItems, clientPayments);

  Future<void> loadItemsForClient(String clientId, {bool force = false}) async {
    if (!force &&
        clientItems.containsKey(clientId) &&
        clientItems[clientId]!.isNotEmpty) return;
    final userId = currentUserId(_supabaseClient);
    if (userId == null) return;

    // 1. Carregamento Ultra Rápido do Cache Offline (Sem travar a tela)
    try {
      final localAccounts = await _service.accountRepository.getCachedList('cached_account_$userId');
      final localAccount = localAccounts.cast<AccountModel?>().firstWhere(
        (a) => a?.clientId == clientId && (a?.active ?? false),
        orElse: () => null,
      );

      if (localAccount != null) {
        final localItems = await _service.itemAccountRepository.getCachedList('cached_item_account_$userId');
        final localPayments = await _service.paymentRepository.getCachedList('cached_payment_$userId');

        clientItems[clientId] = localItems.where((it) => it.accountId == localAccount.id).map((ia) {
          final userItemsCacheKey = 'cached_items_global_$userId';
          final cachedProducts = _service.itemRepository.localDataSource.get(userItemsCacheKey) as List? ?? [];
          final product = cachedProducts
              .map((e) => ItemModel.fromJson(Map<String, dynamic>.from(e)))
              .firstWhere(
                (it) => it.id == ia.itemId,
                orElse: () => ItemModel(description: 'Item de consumo', measurementUnit: 'un'),
              );

          return PurchasedItemModel(
            id: ia.id,
            quantity: ia.quantity,
            unit: product.measurementUnit,
            description: product.description,
            value: 'R\$ ${ia.unitValue.toStringAsFixed(2).replaceAll('.', ',')}',
          );
        }).toList();

        clientPayments[clientId] = localPayments.where((p) => p.accountId == localAccount.id).toList();
        
        final debt = getTotalDebtForClient(clientId);
        accountStatuses[clientId] = debt > 0 ? 'DEVENDO' : localAccount.status;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading offline cache: $e');
    }

    // 2. Chamada em Background para atualizar com dados Online
    try {
      final account = await _service.accountRepository.getByClientId(
        clientId,
        userId,
      );
      if (account?.id == null) {
        clientItems[clientId] = [];
        clientPayments[clientId] = [];
        accountStatuses[clientId] = 'LIMPA';
        _homeViewModel?.updateClientStatus(clientId, 'LIMPA');
        notifyListeners();
        return;
      }

      // Faz as buscas no Supabase em paralelo
      final results = await Future.wait([
        _service.loadItems(account!.id!, userId),
        _service.loadPayments(account.id!, userId),
      ]);

      clientItems[clientId] = results[0] as List<PurchasedItemModel>;
      clientPayments[clientId] = results[1] as List<PaymentModel>;

      await _updateStatus(clientId, account);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading items/payments: $e');
    }
  }

  Future<void> addPaymentToClientAccount(
    String clientId,
    Map<String, dynamic> paymentData,
  ) async {
    final userId = currentUserId(_supabaseClient);
    if (userId == null) return;

    try {
      final account = await _service.accountRepository.getByClientId(
        clientId,
        userId,
      );
      if (account?.id == null) return;

      final double valor = paymentData['valor'] as double;
      final payment = await _service.savePayment(account!.id!, valor, userId);

      if (payment != null) {
        clientPayments[clientId] = [
          ...(clientPayments[clientId] ?? []),
          payment,
        ];
      } else {
        // Fallback offline
        clientPayments[clientId] = [
          ...(clientPayments[clientId] ?? []),
          PaymentModel(
            accountId: account.id!,
            date: DateTime.now(),
            value: valor,
          ),
        ];
      }

      await _updateStatus(clientId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding payment: $e');
    }
  }

  Future<void> addItemsToClientAccount(
    String clientId,
    List<Map<String, dynamic>> items,
  ) async {
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
        final double unitValue =
            double.tryParse(
              itemData['valor']
                  .toString()
                  .replaceAll('R\$ ', '')
                  .replaceAll('.', '')
                  .replaceAll(',', '.'),
            ) ??
            0;

        final item = await _service.getOrCreateItem(description, unit, userId);

        if (item.id != null) {
          await _service.linkItemToAccount(
            item.id!,
            account!.id!,
            quantity,
            unitValue,
            userId,
          );
        }

        newPurchasedItems.add(
          PurchasedItemModel(
            quantity: quantity,
            unit: unit,
            description: description,
            value: itemData['valor'].toString(),
          ),
        );
      }

      clientItems[clientId] = [
        ...(clientItems[clientId] ?? []),
        ...newPurchasedItems,
      ];
      await _updateStatus(clientId);
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
      final account = await _service.accountRepository.getByClientId(
        clientId,
        userId,
      );
      if (account?.id != null) {
        await _service.clearAccount(account!.id!, userId);

        // Limpa localmente
        clientItems[clientId] = [];
        clientPayments[clientId] = [];
        accountStatuses[clientId] = 'LIMPA';

        // Sincroniza com HomeViewModel
        _homeViewModel?.updateClientStatus(clientId, 'LIMPA');

        notifyListeners();
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
    double unitValue,
  ) async {
    final userId = currentUserId(_supabaseClient);
    if (userId == null) return;

    try {
      await _service.updateItemAccount(
        itemAccountId,
        description,
        quantity,
        unitValue,
        userId,
      );

      // Recarrega os itens para garantir que a UI reflita os valores formatados corretamente
      final account = await _service.accountRepository.getByClientId(
        clientId,
        userId,
      );
      if (account?.id != null) {
        clientItems[clientId] = await _service.loadItems(account!.id!, userId);
      }

      await _updateStatus(clientId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  Future<void> _updateStatus(String clientId, [AccountModel? account]) async {
    final userId = currentUserId(_supabaseClient);
    if (userId == null) return;

    final targetAccount = account ?? await _service.accountRepository.getByClientId(clientId, userId);
    if (targetAccount == null) return;

    final debt = getTotalDebtForClient(clientId);
    final newStatus = debt > 0 ? 'DEVENDO' : 'LIMPA';

    if (targetAccount.status != newStatus) {
      final updated = AccountModel(
        id: targetAccount.id,
        clientId: clientId,
        status: newStatus,
        active: targetAccount.active,
        createdAt: targetAccount.createdAt,
      );
      _service.accountRepository.saveForUser(updated, userId);
      accountStatuses[clientId] = newStatus;
      _homeViewModel?.updateClientStatus(clientId, newStatus);
    } else {
      accountStatuses[clientId] = targetAccount.status;
      _homeViewModel?.updateClientStatus(clientId, targetAccount.status);
    }
  }
}
