import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:espetosystem/app/data/models/account_model.dart';
import 'package:espetosystem/app/data/models/item_model.dart';
import 'package:espetosystem/app/data/models/item_account_model.dart';
import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:espetosystem/app/data/models/purchased_item_model.dart';
import 'package:espetosystem/app/data/repositories/account_repository.dart';
import 'package:espetosystem/app/data/repositories/client_repository.dart';
import 'package:espetosystem/app/data/repositories/item_repository.dart';
import 'package:espetosystem/app/data/repositories/item_account_repository.dart';
import 'package:espetosystem/app/data/repositories/payment_repository.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeViewModel extends ChangeNotifier {
  final ClientRepository? _clientRepository;
  final AccountRepository? _accountRepository;
  final ItemRepository? _itemRepository;
  final ItemAccountRepository? _itemAccountRepository;
  final PaymentRepository? _paymentRepository;
  final SupabaseClient _supabaseClient;
  StreamSubscription<AuthState>? _authStateSubscription;
  int _loadGeneration = 0;
  final List<ClientModel> _pendingClients = <ClientModel>[];

  String? _photoPath;

  HomeViewModel({
    AccountRepository? accountRepository,
    ClientRepository? clientRepository,
    ItemRepository? itemRepository,
    ItemAccountRepository? itemAccountRepository,
    PaymentRepository? paymentRepository,
    required SupabaseClient supabaseClient,
  }) : _accountRepository = accountRepository,
       _clientRepository = clientRepository,
       _itemRepository = itemRepository,
       _itemAccountRepository = itemAccountRepository,
       _paymentRepository = paymentRepository,
       _supabaseClient = supabaseClient {
    Future.microtask(loadClients);

    _authStateSubscription = _supabaseClient.auth.onAuthStateChange.listen((
      data,
    ) async {
      final userId = data.session?.user.id;

      if (data.event == AuthChangeEvent.signedOut) {
        _loadGeneration++;
        _clients.clear();
        _pendingClients.clear();
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (userId == null) {
        return;
      }

      await _flushPendingClients(userId);
      await loadClients();
    });
  }

  String? get photoPath => _photoPath;

  void photoPathAnulated() {
    _photoPath = null;
    notifyListeners();
  }

  void setPhotoPath(String path) {
    _photoPath = path;
    notifyListeners();
  }

  String? get _currentUserId =>
      _supabaseClient.auth.currentSession?.user.id ??
      _supabaseClient.auth.currentUser?.id;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<ClientModel> _clients = <ClientModel>[];
  final Map<String, String> _accountStatuses = <String, String>{};
  final Map<String, List<PurchasedItemModel>> _clientItems =
      <String, List<PurchasedItemModel>>{};
  final Map<String, List<PaymentModel>> _clientPayments =
      <String, List<PaymentModel>>{};

  Map<String, String> get accountStatuses => _accountStatuses;
  List<PurchasedItemModel> getItemsForClient(String clientId) =>
      _clientItems[clientId] ?? [];
  List<PaymentModel> getPaymentsForClient(String clientId) =>
      _clientPayments[clientId] ?? [];

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
    final account = await _accountRepository!.getByClientId(clientId);

    if (account != null) {
      final newStatus = debt > 0 ? 'DEVENDO' : 'LIMPA';
      if (account.status != newStatus) {
        await _accountRepository!.saveForUser(
          AccountModel(id: account.id, clientId: clientId, status: newStatus),
          userId,
        );
        _accountStatuses[clientId] = newStatus;
        notifyListeners();
      }
    }
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
      final account = await _accountRepository!.getByClientId(clientId);
      if (account?.id == null) {
        if (!_clientItems.containsKey(clientId)) {
          _clientItems[clientId] = [];
          notifyListeners();
        }
        return;
      }

      final itemAccounts = await _itemAccountRepository!.getByAccountId(
        account!.id!,
      );
      final List<PurchasedItemModel> loadedItems = [];

      for (final ia in itemAccounts) {
        final itemData = await _itemRepository!.remoteDataSource.fetchById(
          _itemRepository!.tableName,
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
            _paymentRepository!.tableName,
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

  Future<void> loadClients() async {
    final userId = _currentUserId;
    if (_clientRepository == null || userId == null) return;

    final int generation = ++_loadGeneration;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _clientRepository.getClients(userId);
      if (generation != _loadGeneration) return;

      _clients.clear();
      _clients.addAll(result);

      if (_accountRepository != null) {
        for (final client in _clients) {
          if (client.id != null) {
            final account = await _accountRepository.getByClientId(client.id!);
            if (account != null) {
              _accountStatuses[client.id!] = account.status;
            }
          }
        }
      }
    } catch (e) {
      if (generation != _loadGeneration) return;

      debugPrint('Error loading clients: $e');
    } finally {
      if (generation != _loadGeneration) return;

      _isLoading = false;
      notifyListeners();
    }
  }

  int _selectedFilterIndex = 0;
  bool _ascendingOrder = true;
  String _searchQuery = '';

  List<ClientModel> get clients => _clients;
  int get selectedFilterIndex => _selectedFilterIndex;
  bool get ascendingOrder => _ascendingOrder;
  String get searchQuery => _searchQuery;

  List<ClientModel> get visibleClients {
    final query = _searchQuery.trim().toLowerCase();

    final filtered =
        _clients.where((client) {
          final matchesSearch =
              query.isEmpty ||
              client.name.toLowerCase().contains(query) ||
              client.description.toLowerCase().contains(query) ||
              client.cpf.toLowerCase().contains(query) ||
              client.phoneNumber.toLowerCase().contains(query) ||
              (client.address?.street.toLowerCase().contains(query) ?? false) ||
              (client.address?.neighborhood.toLowerCase().contains(query) ??
                  false);

          // Filtering by status is now disabled or should be implemented via Account
          const matchesFilter = true;

          return matchesSearch && matchesFilter;
        }).toList();

    filtered.sort((a, b) {
      final comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return _ascendingOrder ? comparison : -comparison;
    });

    return filtered;
  }

  void toggleSortOrder() {
    _ascendingOrder = !_ascendingOrder;
    notifyListeners();
  }

  void setSelectedFilterIndex(int index) {
    _selectedFilterIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addClient(ClientModel client) async {
    final userId = _currentUserId;
    _loadGeneration++;

    _clients.add(client);
    if (userId == null) {
      _pendingClients.add(client);
    }
    notifyListeners();

    if (_clientRepository == null || userId == null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final savedClient = await _clientRepository.saveClient(client, userId);
      if (savedClient != null) {
        final index = _clients.indexOf(client);
        if (index != -1) {
          _clients[index] = savedClient;
        } else {
          _clients.add(savedClient);
        }
        _pendingClients.remove(client);
        _selectedFilterIndex = 0;
        _searchQuery = '';

        if (_accountRepository != null && savedClient.id != null) {
          await _accountRepository.saveForUser(
            AccountModel(clientId: savedClient.id!, status: 'LIMPA'),
            userId,
          );
        }
      }
    } catch (e) {
      debugPrint('Error adding client: $e');
      _clients.remove(client);
      _pendingClients.remove(client);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _flushPendingClients(String userId) async {
    if (_clientRepository == null || _pendingClients.isEmpty) {
      return;
    }

    final pendingSnapshot = List<ClientModel>.from(_pendingClients);
    _pendingClients.clear();

    for (final pendingClient in pendingSnapshot) {
      final savedClient = await _clientRepository.saveClient(
        pendingClient,
        userId,
      );
      if (savedClient == null) {
        _pendingClients.add(pendingClient);
        continue;
      }

      final index = _clients.indexOf(pendingClient);
      if (index != -1) {
        _clients[index] = savedClient;
      } else {
        _clients.add(savedClient);
      }

      if (_accountRepository != null && savedClient.id != null) {
        await _accountRepository.saveForUser(
          AccountModel(clientId: savedClient.id!, status: 'LIMPA'),
          userId,
        );
      }
    }

    notifyListeners();
  }

  Future<void> markClientAccountAsDevendo(String clientId) async {
    final userId = _currentUserId;
    if (_accountRepository == null || userId == null) {
      return;
    }

    await _accountRepository.saveForUser(
      AccountModel(clientId: clientId, status: 'DEVENDO'),
      userId,
    );

    _accountStatuses[clientId] = 'DEVENDO';
    notifyListeners();
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
          final existingItems = await _itemRepository!.remoteDataSource
              .fetchWithFilter(
                _itemRepository!.tableName,
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
          item = await _itemRepository!.saveForUser(
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
            await _itemAccountRepository!.saveForUser(
              ItemAccountModel(
                quantity: quantity,
                itemId: item!.id!,
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
      final account = await _accountRepository!.getByClientId(clientId);
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
      final payment = await _paymentRepository!.saveForUser(
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

  Future<ClientModel?> saveClient(ClientModel client) async {
    final userId = _currentUserId;
    if (_clientRepository == null || userId == null) return null;

    final saved = await _clientRepository!.saveClient(client, userId);
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

    await _clientRepository!.deleteClient(clientId, userId);
    _clients.removeWhere((c) => c.id == clientId);
    _accountStatuses.remove(clientId);
    _clientItems.remove(clientId);
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
