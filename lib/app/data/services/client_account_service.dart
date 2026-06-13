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
    var account = await accountRepository.getByClientId(clientId);
    
    // Se não existir conta ativa, cria uma NOVA do zero
    if (account == null) {
      account = await accountRepository.saveForUser(
        AccountModel(clientId: clientId, status: 'LIMPA', active: true),
        userId,
      );
    } 
    
    return account;
  }

  Future<List<PurchasedItemModel>> loadItems(String accountId) async {
    final itemAccounts = await itemAccountRepository.getByAccountId(accountId);
    final List<PurchasedItemModel> loadedItems = [];

    for (final ia in itemAccounts) {
      final itemData = await itemRepository.remoteDataSource.fetchById(
        itemRepository.tableName,
        ia.itemId,
      );
      final item = ItemModel.fromJson(itemData);

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
    return loadedItems;
  }

  Future<List<PaymentModel>> loadPayments(String accountId) async {
    final paymentsRaw = await paymentRepository.remoteDataSource
        .fetchWithFilter(paymentRepository.tableName, 'account_id', accountId);
    return paymentsRaw.map((p) => PaymentModel.fromJson(p)).toList();
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
