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

  Future<AccountModel?> getOrCreateAccount(String clientId, String userId) async {
    var account = await accountRepository.getByClientId(clientId);
    if (account == null) {
      account = await accountRepository.saveForUser(
        AccountModel(clientId: clientId, status: 'DEVENDO'),
        userId,
      );
    } else if (account.status != 'DEVENDO') {
      account = await accountRepository.saveForUser(
        AccountModel(id: account.id, clientId: clientId, status: 'DEVENDO'),
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
    final paymentsRaw = await paymentRepository.remoteDataSource.fetchWithFilter(
      paymentRepository.tableName,
      'account_id',
      accountId,
    );
    return paymentsRaw.map((p) => PaymentModel.fromJson(p)).toList();
  }

  Future<PaymentModel?> savePayment(String accountId, double valor, String userId) async {
    final paymentModel = PaymentModel(
      accountId: accountId,
      date: DateTime.now(),
      value: valor,
    );
    return await paymentRepository.saveForUser(paymentModel, userId);
  }

  Future<ItemModel> getOrCreateItem(String description, String unit, String userId) async {
    ItemModel? item;
    try {
      final existingItems = await itemRepository.remoteDataSource.fetchWithFilter(
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

    if (item == null) {
      item = await itemRepository.saveForUser(
        ItemModel(description: description, measurementUnit: unit),
        userId,
      );
    }
    return item!;
  }

  Future<void> linkItemToAccount(String itemId, String accountId, int quantity, double unitValue, String userId) async {
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
}
