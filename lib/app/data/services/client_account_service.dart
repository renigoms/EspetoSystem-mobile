import 'package:espetosystem/app/data/models/account_model.dart';
import 'package:espetosystem/app/data/models/item_account_model.dart';
import 'package:espetosystem/app/data/models/item_model.dart';
import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:espetosystem/app/data/models/purchased_item_model.dart';
import 'package:espetosystem/app/data/repositories/account_repository.dart';
import 'package:espetosystem/app/data/repositories/item_account_repository.dart';
import 'package:espetosystem/app/data/repositories/item_repository.dart';
import 'package:espetosystem/app/data/repositories/payment_repository.dart';
import 'package:flutter/foundation.dart';

class ClientAccountService {
  final AccountRepository accountRepository;
  final ItemRepository itemRepository;
  final ItemAccountRepository itemAccountRepository;
  final PaymentRepository paymentRepository;

  ClientAccountService({
    required this.accountRepository,
    required this.itemRepository,
    required this.itemAccountRepository,
    required this.paymentRepository,
  });

  Future<AccountModel?> getOrCreateAccount(
    String clientId,
    String userId,
  ) async {
    // Busca a conta ativa atual
    var account = await accountRepository.getByClientId(clientId, userId);
    
    // Se não existir conta ativa, cria uma NOVA do zero
    if (account == null) {
      account = await accountRepository.saveForUser(
        AccountModel(clientId: clientId, status: 'LIMPA', active: true),
        userId,
      );
    } 
    
    return account;
  }

  Future<List<PurchasedItemModel>> loadItems(String accountId, String userId) async {
    final itemAccounts = await itemAccountRepository.getByAccountId(accountId, userId);
    
    // Busca itens pendentes na fila de sincronização
    final syncQueueKey = 'sync_queue_${itemAccountRepository.tableName}_$userId';
    final queue = itemAccountRepository.localDataSource.get(syncQueueKey) as List? ?? [];
    final List<ItemAccountModel> pendingIA = queue
        .map((e) => itemAccountRepository.fromJson(Map<String, dynamic>.from(e)))
        .where((ia) => ia.accountId == accountId)
        .toList();

    // Combina itens já sincronizados com os pendentes
    final allIA = [...itemAccounts];
    for (var pia in pendingIA) {
      if (!allIA.any((ia) => ia.id == pia.id)) {
        allIA.add(pia);
      }
    }

    final List<PurchasedItemModel> loadedItems = [];

    // Tenta carregar todos os itens para cache local primeiro para agilizar se estiver offline
    final userItemsCacheKey = 'cached_items_global_$userId';
    List<ItemModel> allItems = [];
    
    if (await itemRepository.networkInfo.isConnected) {
      try {
        allItems = await itemRepository.getAllForUser(userId);
        await itemRepository.localDataSource.save(userItemsCacheKey, allItems.map((e) => e.toJson()).toList());
      } catch (e) {
        debugPrint('Error fetching all items for offline cache: $e');
      }
    }

    if (allItems.isEmpty) {
      final cached = itemRepository.localDataSource.get(userItemsCacheKey) as List?;
      if (cached != null) {
        allItems = cached.map((e) => ItemModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    }

    // Busca também produtos na fila de sincronização (novos produtos criados offline)
    final productSyncQueueKey = 'sync_queue_${itemRepository.tableName}_$userId';
    final productQueue = itemRepository.localDataSource.get(productSyncQueueKey) as List? ?? [];
    final List<ItemModel> pendingProducts = productQueue
        .map((e) => itemRepository.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    
    final combinedProducts = [...allItems, ...pendingProducts];

    for (final ia in allIA) {
      ItemModel? item;
      
      // Busca no cache combinado (sincronizados + pendentes)
      try {
        item = combinedProducts.firstWhere((it) => it.id == ia.itemId);
      } catch (_) {
        // Fallback para busca individual se não achou no cache global
        if (await itemRepository.networkInfo.isConnected) {
          try {
            final itemData = await itemRepository.remoteDataSource.fetchById(
              itemRepository.tableName,
              ia.itemId,
            );
            item = ItemModel.fromJson(itemData);
          } catch (e) {
            debugPrint('Error fetching individual item ${ia.itemId}: $e');
          }
        }
      }

      if (item != null) {
        loadedItems.add(
          PurchasedItemModel(
            id: ia.id,
            quantity: ia.quantity,
            unit: item.measurementUnit,
            description: item.description,
            value: 'R\$ ${ia.unitValue.toStringAsFixed(2).replaceAll('.', ',')}',
          ),
        );
      }
    }
    return loadedItems;
  }

  Future<List<PaymentModel>> loadPayments(String accountId, String userId) async {
    final userCacheKey = 'cached_payments_all_$userId';
    List<PaymentModel> syncedPayments = [];
    
    if (await paymentRepository.networkInfo.isConnected) {
      try {
        final paymentsRaw = await paymentRepository.remoteDataSource
            .fetchWithFilter(paymentRepository.tableName, 'account_id', accountId);
        
        syncedPayments = paymentsRaw.map((p) => PaymentModel.fromJson(p)).toList();
        
        // Atualiza cache global de pagamentos
        for (final p in syncedPayments) {
          await paymentRepository.upsertCachedUserModel(userCacheKey, p.toJson());
        }
      } catch (e) {
        debugPrint('Error loading payments: $e');
      }
    }

    if (syncedPayments.isEmpty) {
      final cached = await paymentRepository.getCachedList(userCacheKey);
      syncedPayments = cached.where((p) => p.accountId == accountId).toList();
    }

    // Busca pagamentos pendentes na fila
    final syncQueueKey = 'sync_queue_${paymentRepository.tableName}_$userId';
    final queue = paymentRepository.localDataSource.get(syncQueueKey) as List? ?? [];
    final List<PaymentModel> pendingPayments = queue
        .map((e) => paymentRepository.fromJson(Map<String, dynamic>.from(e)))
        .where((p) => p.accountId == accountId)
        .toList();

    // Combina listas
    final allPayments = [...syncedPayments];
    for (var pp in pendingPayments) {
      if (!allPayments.any((p) => p.id == pp.id)) {
        allPayments.add(pp);
      }
    }

    return allPayments;
  }

  Future<PaymentModel?> savePayment(
    String accountId,
    double valor,
    String userId,
  ) async {
    final paymentModel = PaymentModel(
      accountId: accountId,
      date: DateTime.now(),
      value: valor,
    );
    return await paymentRepository.saveForUser(paymentModel, userId);
  }

  Future<ItemModel> getOrCreateItem(
    String description,
    String unit,
    String userId,
  ) async {
    ItemModel? item;
    try {
      final existingItems = await itemRepository.remoteDataSource
          .fetchWithFilter(
            itemRepository.tableName,
            'description',
            description,
          );
      if (existingItems.isNotEmpty) {
        item = ItemModel.fromJson(existingItems.first);
      }
    } catch (e) {
      debugPrint('Error searching for existing item: $e');
    }

    item ??= await itemRepository.saveForUser(
      ItemModel(description: description, measurementUnit: unit),
      userId,
    );
    return item!;
  }

  Future<void> linkItemToAccount(
    String itemId,
    String accountId,
    int quantity,
    double unitValue,
    String userId,
  ) async {
    await itemAccountRepository.saveForUser(
      ItemAccountModel(
        quantity: quantity,
        itemId: itemId,
        accountId: accountId,
        unitValue: unitValue,
      ),
      userId,
    );
  }

  Future<void> deleteItemAccount(String id, String userId) async {
    await itemAccountRepository.deleteById(id, userId);
  }

  Future<void> deletePayment(String id, String userId) async {
    await paymentRepository.deleteById(id, userId);
  }

  Future<void> clearAccount(String accountId, String userId) async {
    final results = await accountRepository.remoteDataSource.fetchWithFilter(
      accountRepository.tableName,
      'id',
      accountId,
    );

    if (results.isNotEmpty) {
      final current = AccountModel.fromJson(results.first);
      final updated = AccountModel(
        id: accountId,
        clientId: current.clientId,
        createdAt: current.createdAt,
        status: 'PAGA',
        active: false,
      );
      await accountRepository.saveForUser(updated, userId);
    }
  }

  Future<void> updateItemAccount(
    String id,
    String description,
    int quantity,
    double unitValue,
    String userId,
  ) async {
    final results = await itemAccountRepository.remoteDataSource
        .fetchWithFilter(itemAccountRepository.tableName, 'id', id);

    if (results.isNotEmpty) {
      final current = ItemAccountModel.fromJson(results.first);

      final itemData = await itemRepository.remoteDataSource.fetchById(
        itemRepository.tableName,
        current.itemId,
      );
      final originalItem = ItemModel.fromJson(itemData);

      final newItem = await getOrCreateItem(
        description,
        originalItem.measurementUnit,
        userId,
      );

      final updated = ItemAccountModel(
        id: id,
        quantity: quantity,
        unitValue: unitValue,
        itemId: newItem.id!,
        accountId: current.accountId,
        createdAt: current.createdAt,
      );
      await itemAccountRepository.saveForUser(updated, userId);
    }
  }
}
