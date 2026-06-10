import 'package:espetosystem/app/data/models/account_model.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:espetosystem/app/data/models/item_account_model.dart';
import 'package:espetosystem/app/data/models/item_model.dart';
import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:espetosystem/app/data/models/purchased_item_model.dart';
import 'package:espetosystem/app/data/repositories/account_repository.dart';
import 'package:espetosystem/app/data/repositories/client_repository.dart';
import 'package:espetosystem/app/data/repositories/item_account_repository.dart';
import 'package:espetosystem/app/data/repositories/item_repository.dart';
import 'package:espetosystem/app/data/repositories/payment_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientViewModel extends ChangeNotifier {
  final ClientRepository? _clientRepository;
  final SupabaseClient _supabaseClient;
  final AccountRepository? _accountRepository;
  final ItemRepository? _itemRepository;
  final ItemAccountRepository? _itemAccountRepository;
  final PaymentRepository? _paymentRepository;

  final List<ClientModel> _clients = <ClientModel>[];
  final Map<String, String> _accountStatuses = <String, String>{};
  final Map<String, List<PurchasedItemModel>> _clientItems =
      <String, List<PurchasedItemModel>>{};
  final Map<String, List<PaymentModel>> _clientPayments =
      <String, List<PaymentModel>>{};
  List<PurchasedItemModel> getItemsForClient(String clientId) =>
      _clientItems[clientId] ?? [];
  List<PaymentModel> getPaymentsForClient(String clientId) =>
      _clientPayments[clientId] ?? [];

  bool _isLoading = false;

  ClientViewModel(
    this._clientRepository,
    this._supabaseClient,
    this._accountRepository,
    this._itemRepository,
    this._itemAccountRepository,
    this._paymentRepository,
  ) {
    _clients.clear();
    _isLoading = false;
  }

  bool get isLoading => _isLoading;

  String? get _currentUserId =>
      _supabaseClient.auth.currentSession?.user.id ??
      _supabaseClient.auth.currentUser?.id;

  double getTotalDebtForClient(String clientId) {
    final items = _clientItems[clientId] ?? [];
    final payments = _clientPayments[clientId] ?? [];

    final itemsTotal = items.fold(0.0, (total, item) {
      final double unitValue =
          double.tryParse(
            item.value
                .replaceAll('R\$ ', '')
                .replaceAll('.', '')
                .replaceAll(',', '.'),
          ) ??
          0;
      return total + (item.quantity * unitValue);
    });

    final paymentsTotal = payments.fold(
      0.0,
      (total, payment) => total + payment.value,
    );

    final debt = itemsTotal - paymentsTotal;
    return debt > 0 ? debt : 0.0;
  }

  Future<void> _updateAccountStatusIfNeeded(String clientId) async {
    final userId = _currentUserId;
    if (_accountRepository == null || userId == null) return;

    final debt = getTotalDebtForClient(clientId);
    final account = await _accountRepository.getByClientId(clientId);

    if (account != null) {
      final newStatus = debt > 0 ? 'DEVENDO' : 'LIMPA';
      if (account.status != newStatus) {
        await _accountRepository.saveForUser(
          AccountModel(id: account.id, clientId: clientId, status: newStatus),
          userId,
        );
        _accountStatuses[clientId] = newStatus;
        notifyListeners();
      }
    }
  }

  Future<ClientModel?> updateClient(ClientModel client) async {
    final userId = _currentUserId;
    if (_clientRepository == null || userId == null) return null;

    final saved = await _clientRepository.saveClient(client, userId);
    if (saved != null) {
      final index = _clients.indexWhere((c) => c.id == saved.id);
      if (index != -1) {
        _clients[index] = saved;
      } else {
        _clients.add(saved);
      }
      notifyListeners();
    }
    return saved;
  }

  Future<void> deleteClient(String clientId) async {
    final userId = _currentUserId;
    if (_clientRepository == null || userId == null) return;

    await _clientRepository.deleteClient(clientId, userId);
    _clients.removeWhere((c) => c.id == clientId);
    _accountStatuses.remove(clientId);
    _clientItems.remove(clientId);
    notifyListeners();
  }

  Future<void> loadItemsForClient(String clientId, {bool force = false}) async {
    // Se já temos itens e não estamos forçando o reload, não faz nada
    if (!force &&
        _clientItems.containsKey(clientId) &&
        _clientItems[clientId]!.isNotEmpty) {
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
        if (!_clientItems.containsKey(clientId)) {
          _clientItems[clientId] = [];
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
      _clientPayments[clientId] = loadedPayments;

      // Só atualiza se o que veio do banco for diferente ou se estivermos forçando
      _clientItems[clientId] = loadedItems;
      await _updateAccountStatusIfNeeded(clientId);
      notifyListeners();
    } catch (e) {
      debugPrint('DEBUG: Error loading items for client $clientId: $e');
    }
  }

  Future<void> addPaymentToClientAccount(
    String clientId,
    Map<String, dynamic> paymentData,
  ) async {
    final userId = _currentUserId;
    debugPrint(
      'DEBUG PAYMENT: Starting addPaymentToClientAccount for client: $clientId',
    );
    if (userId == null ||
        _accountRepository == null ||
        _paymentRepository == null) {
      debugPrint('DEBUG PAYMENT: Missing repositories or userId');
      return;
    }

    try {
      final account = await _accountRepository.getByClientId(clientId);
      if (account?.id == null) {
        debugPrint('DEBUG PAYMENT: Account not found for client: $clientId');
        return;
      }
      debugPrint('DEBUG PAYMENT: Found account: ${account!.id}');

      final double valor = paymentData['valor'] as double;
      debugPrint('DEBUG PAYMENT: Payment value to save: $valor');

      final paymentModel = PaymentModel(
        accountId: account.id!,
        date: DateTime.now(),
        value: valor,
      );

      debugPrint('DEBUG PAYMENT: Calling paymentRepository.saveForUser');
      final payment = await _paymentRepository.saveForUser(
        paymentModel,
        userId,
      );

      if (payment != null) {
        debugPrint(
          'DEBUG PAYMENT: Payment saved successfully (local or remote). ID: ${payment.id}',
        );
        final currentPayments = _clientPayments[clientId] ?? [];
        _clientPayments[clientId] = [...currentPayments, payment];

        // Recalculate debt and update status if necessary
        debugPrint('DEBUG PAYMENT: Updating account status and debt.');
        await _updateAccountStatusIfNeeded(clientId);
        notifyListeners();
        debugPrint('DEBUG PAYMENT: UI notified.');
      } else {
        debugPrint(
          'DEBUG PAYMENT: paymentRepository.saveForUser returned null!',
        );
        // Fallback para offline-first imediato na UI
        final fallbackPayment = PaymentModel(
          accountId: account.id!,
          date: DateTime.now(),
          value: valor,
        );
        final currentPayments = _clientPayments[clientId] ?? [];
        _clientPayments[clientId] = [...currentPayments, fallbackPayment];
        await _updateAccountStatusIfNeeded(clientId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('DEBUG PAYMENT: Critical error adding payment: $e');
    }
  }

  Future<void> addItemsToClientAccount(
    String clientId,
    List<Map<String, dynamic>> items,
  ) async {
    final userId = _currentUserId;
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
      final currentItems = _clientItems[clientId] ?? [];
      _clientItems[clientId] = [...currentItems, ...newPurchasedItems];

      _accountStatuses[clientId] = 'DEVENDO';
      notifyListeners();
      debugPrint('DEBUG: Process completed. UI notified.');
    } catch (e) {
      debugPrint('DEBUG: Critical error in addItemsToClientAccount: $e');
    }
  }
}
