import 'package:espetosystem/app/UI/client/view_model/base_view_model.dart';
import 'package:espetosystem/app/core/components/view_model_components.dart';
import 'package:espetosystem/app/data/models/account_model.dart';
import 'package:espetosystem/app/data/models/item_account_model.dart';
import 'package:espetosystem/app/data/models/item_model.dart';
import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:espetosystem/app/data/models/purchased_item_model.dart';
import 'package:espetosystem/app/data/repositories/account_repository.dart';
import 'package:espetosystem/app/data/repositories/item_account_repository.dart';
import 'package:espetosystem/app/data/repositories/item_repository.dart';
import 'package:espetosystem/app/data/repositories/payment_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemViewModel extends BaseViewModel {
  final ItemRepository? _itemRepository;
  final ItemAccountRepository? _itemAccountRepository;
  final AccountRepository? _accountRepository;
  final SupabaseClient _supabaseClient;
  final PaymentRepository? _paymentRepository;

  List<PurchasedItemModel> getItemsForClient(String clientId) =>
      clientItems[clientId] ?? [];
  List<PaymentModel> getPaymentsForClient(String clientId) =>
      clientPayments[clientId] ?? [];

  ItemViewModel(
    this._itemRepository,
    this._itemAccountRepository,
    this._accountRepository,
    this._supabaseClient,
    this._paymentRepository,
  ) : super(_supabaseClient);

  double getTotalDebtForClient(String clientId) =>
      totalDebtForClient(clientId, clientItems, clientPayments);

  Future<void> loadItemsForClient(String clientId, {bool force = false}) async {
    // Se já temos itens e não estamos forçando o reload, não faz nada
    if (!force &&
        clientItems.containsKey(clientId) &&
        clientItems[clientId]!.isNotEmpty) {
      return;
    }

    debugPrint('DEBUG: Loading items for client: $clientId');
    if (_accountRepository == null ||
        _itemRepository == null ||
        _itemAccountRepository == null) {
      return;
    }

    try {
      final account = await _accountRepository.getByClientId(clientId);
      if (account?.id == null) {
        if (!clientItems.containsKey(clientId)) {
          clientItems[clientId] = [];
          notifyListeners();
        }
        return;
      }

      final itemAccounts = await _itemAccountRepository.getByAccountId(
        account!.id!,
      );
      final List<PurchasedItemModel> loadedItems = [];

      for (final ia in itemAccounts) {
        final itemData = await _itemRepository.remoteDataSource.fetchById(
          _itemRepository.tableName,
          ia.itemId,
        );
        final item = ItemModel.fromJson(itemData);

        loadedItems.add(
          PurchasedItemModel(
            quantity: ia.quantity,
            unit: item.measurementUnit,
            description: item.description,
            value:
                'R\$ ${ia.unitValue.toStringAsFixed(2).replaceAll('.', ',')}',
          ),
        );
      }

      // Load payments
      final paymentsRaw = await _paymentRepository!.remoteDataSource
          .fetchWithFilter(
            _paymentRepository.tableName,
            'account_id',
            account.id!,
          );
      final loadedPayments =
          paymentsRaw.map((p) => PaymentModel.fromJson(p)).toList();
      clientPayments[clientId] = loadedPayments;

      // Só atualiza se o que veio do banco for diferente ou se estivermos forçando
      clientItems[clientId] = loadedItems;
      accountStatuses[clientId] = await getStatusIfNeeded(
        clientId,
        currentUserId(_supabaseClient),
        _accountRepository,
        totalDebtForClient(clientId, clientItems, clientPayments),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('DEBUG: Error loading items for client $clientId: $e');
    }
  }

  Future<void> addItemsToClientAccount(
    String clientId,
    List<Map<String, dynamic>> items,
  ) async {
    final userId = currentUserId(_supabaseClient);
    debugPrint('DEBUG: Starting to add items to client account: $clientId');
    if (userId == null ||
        _accountRepository == null ||
        _itemRepository == null ||
        _itemAccountRepository == null) {
      debugPrint('DEBUG: Missing repositories or userId');
      return;
    }

    try {
      // 1. Get or create account
      var account = await _accountRepository.getByClientId(clientId);
      if (account == null) {
        debugPrint('DEBUG: Creating new account for client');
        account = await _accountRepository.saveForUser(
          AccountModel(clientId: clientId, status: 'DEVENDO'),
          userId,
        );
      } else if (account.status != 'DEVENDO') {
        debugPrint('DEBUG: Updating account status to DEVENDO');
        account = await _accountRepository.saveForUser(
          AccountModel(id: account.id, clientId: clientId, status: 'DEVENDO'),
          userId,
        );
      }

      if (account?.id == null) {
        debugPrint('DEBUG: Failed to obtain valid account ID');
        return;
      }

      final List<PurchasedItemModel> newPurchasedItems = [];

      for (final itemData in items) {
        final description = itemData['descricao'].toString();
        final quantity = int.tryParse(itemData['quantidade'].toString()) ?? 0;
        final unidade = itemData['unidade']?.toString() ?? 'UND';

        final String rawValue = itemData['valor']
            .toString()
            .replaceAll('R\$ ', '')
            .replaceAll('.', '')
            .replaceAll(',', '.');
        final unitValue = double.tryParse(rawValue) ?? 0;

        debugPrint('DEBUG: Saving item: $description ($unidade)');

        // 2. Procurar se já existe um item com essa descrição para evitar duplicidade
        ItemModel? item;
        try {
          final existingItems = await _itemRepository.remoteDataSource
              .fetchWithFilter(
                _itemRepository.tableName,
                'description',
                description,
              );

          if (existingItems.isNotEmpty) {
            debugPrint(
              'DEBUG: Existing item found with same description. Reusing.',
            );
            item = ItemModel.fromJson(existingItems.first);
          }
        } catch (e) {
          debugPrint('DEBUG: Error searching for existing item: $e');
        }

        // Se não encontrou, cria um novo
        if (item == null) {
          debugPrint('DEBUG: Item not found. Creating new one.');
          item = await _itemRepository.saveForUser(
            ItemModel(description: description, measurementUnit: unidade),
            userId,
          );
        }

        if (item?.id != null) {
          debugPrint(
            'DEBUG: Item ID identified: ${item!.id}. Linking to account.',
          );
          // 3. Link to account
          try {
            await _itemAccountRepository.saveForUser(
              ItemAccountModel(
                quantity: quantity,
                itemId: item.id!,
                accountId: account!.id!,
                unitValue: unitValue,
              ),
              userId,
            );
            debugPrint('DEBUG: Linked item to account successfully');
          } catch (e) {
            debugPrint('DEBUG: Error linking item to account: $e');
          }

          newPurchasedItems.add(
            PurchasedItemModel(
              quantity: quantity,
              unit: unidade,
              description: description,
              value: itemData['valor'].toString(),
            ),
          );
        } else {
          debugPrint(
            'DEBUG: Item saved locally but has no ID yet (offline or error)',
          );
          // Adiciona à lista visual mesmo sem ID para o usuário ver na hora
          newPurchasedItems.add(
            PurchasedItemModel(
              quantity: quantity,
              unit: unidade,
              description: description,
              value: itemData['valor'].toString(),
            ),
          );
        }
      }

      // Update local cache
      final currentItems = clientItems[clientId] ?? [];
      clientItems[clientId] = [...currentItems, ...newPurchasedItems];

      accountStatuses[clientId] = 'DEVENDO';
      notifyListeners();
      debugPrint('DEBUG: Process completed. UI notified.');
    } catch (e) {
      debugPrint('DEBUG: Critical error in addItemsToClientAccount: $e');
    }
  }
}
