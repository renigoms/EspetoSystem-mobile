import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:espetosystem/app/core/components/view_model_components.dart';
import 'package:espetosystem/app/data/models/account_model.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:espetosystem/app/data/models/item_account_model.dart';
import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:espetosystem/app/data/models/purchased_item_model.dart';
import 'package:espetosystem/app/data/repositories/account_repository.dart';
import 'package:espetosystem/app/data/repositories/client_repository.dart';
import 'package:espetosystem/app/data/repositories/item_account_repository.dart';
import 'package:espetosystem/app/data/repositories/item_repository.dart';
import 'package:espetosystem/app/data/repositories/payment_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeViewModel extends ChangeNotifier {
  final ClientRepository? _clientRepository;
  final AccountRepository? _accountRepository;
  final ItemAccountRepository? _itemAccountRepository;
  final PaymentRepository? _paymentRepository;
  final ItemRepository? _itemRepository;
  final SupabaseClient _supabaseClient;
  StreamSubscription<AuthState>? _authStateSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  int _loadGeneration = 0;
  final List<ClientModel> _pendingClients = <ClientModel>[];

  String? _photoPath;

  HomeViewModel({
    AccountRepository? accountRepository,
    ClientRepository? clientRepository,
    ItemAccountRepository? itemAccountRepository,
    PaymentRepository? paymentRepository,
    ItemRepository? itemRepository,
    required SupabaseClient supabaseClient,
  }) : _accountRepository = accountRepository,
       _clientRepository = clientRepository,
       _itemAccountRepository = itemAccountRepository,
       _paymentRepository = paymentRepository,
       _itemRepository = itemRepository,
       _supabaseClient = supabaseClient {
    Future.microtask(loadClients);

    _authStateSubscription = _supabaseClient.auth.onAuthStateChange.listen((
      data,
    ) async {
      final userId = data.session?.user.id;

      if (data.event == AuthChangeEvent.signedOut) {
        _loadGeneration++;
        _clients.clear();
        _isLoading = false;
        _pendingClients.clear();
        notifyListeners();
        return;
      }

      if (userId == null) {
        return;
      }

      await _flushPendingClients(userId);
      await loadClients();
    });

    // Listener de conectividade para sincronização automática
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) async {
      final isOnline = !results.contains(ConnectivityResult.none);
      if (isOnline) {
        final userId = currentUserId(_supabaseClient);
        if (userId != null) {
          debugPrint('Back online! Starting full synchronization...');
          await syncAll(userId);
          await loadClients();
        }
      }
    });
  }

  Future<void> syncAll(String userId) async {
    await _clientRepository?.syncWithRemote(userId);
    await _accountRepository?.syncWithRemote(userId);
    
    // Sync items first to get real IDs
    final itemMappings = await _itemRepository?.syncWithRemote(userId) ?? {};
    
    if (itemMappings.isNotEmpty && _itemAccountRepository != null) {
      // Update pending itemAccounts with real item IDs
      final syncQueueKey = 'sync_queue_${_itemAccountRepository.tableName}_$userId';
      final queue = _itemAccountRepository.localDataSource.get(syncQueueKey) as List? ?? [];
      if (queue.isNotEmpty) {
        final List<Map<String, dynamic>> updatedQueue = [];
        bool changed = false;
        for (var item in queue) {
          final data = Map<String, dynamic>.from(item);
          final oldItemId = data['item_id']?.toString();
          if (oldItemId != null && itemMappings.containsKey(oldItemId)) {
            data['item_id'] = itemMappings[oldItemId];
            changed = true;
          }
          updatedQueue.add(data);
        }
        if (changed) {
          await _itemAccountRepository.localDataSource.save(syncQueueKey, updatedQueue);
        }
      }
    }

    await _itemAccountRepository?.syncWithRemote(userId);
    await _paymentRepository?.syncWithRemote(userId);
    debugPrint('Synchronization finished.');
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

  // String? get _currentUserId =>
  //     _supabaseClient.auth.currentSession?.user.id ??
  //     _supabaseClient.auth.currentUser?.id;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<ClientModel> _clients = <ClientModel>[];
  final Map<String, String> _accountStatuses = <String, String>{};
  final Map<String, DateTime?> _lastPaymentDates = <String, DateTime?>{};
  final Map<String, List<PurchasedItemModel>> _clientItems =
      <String, List<PurchasedItemModel>>{};
  final Map<String, List<PaymentModel>> _clientPayments =
      <String, List<PaymentModel>>{};

  Map<String, String> get accountStatuses => _accountStatuses;
  List<PurchasedItemModel> getItemsForClient(String clientId) =>
      _clientItems[clientId] ?? [];
  List<PaymentModel> getPaymentsForClient(String clientId) =>
      _clientPayments[clientId] ?? [];

  Future<void> loadClients() async {
    final userId = currentUserId(_supabaseClient);
    if (_clientRepository == null || userId == null) return;

    final int generation = ++_loadGeneration;
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Busca Clientes (já lida com cache no repositório)
      final clientsResult = await _clientRepository.getClients(userId);
      if (generation != _loadGeneration) return;

      _clients.clear();
      _clients.addAll(clientsResult);

      if (_clients.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Busca de dados em lote (Bulk fetch) para performance e offline
      final clientIds = _clients.map((c) => c.id!).where((id) => id.isNotEmpty).toList();
      
      if (_accountRepository != null && clientIds.isNotEmpty) {
        // Busca todas as contas dos clientes de uma vez
        final allAccounts = await _accountRepository.getAccountsByClientIds(clientIds, userId);
        final accountIds = allAccounts.map((a) => a.id!).where((id) => id.isNotEmpty).toList();

        if (accountIds.isNotEmpty && _itemAccountRepository != null && _paymentRepository != null) {
          // Busca todos os itens e pagamentos de todas as contas de uma vez
          final allItems = await _itemAccountRepository.getItemsByAccountIds(accountIds, userId);
          final allPayments = await _paymentRepository.getPaymentsByAccountIds(accountIds, userId);

          // Adiciona itens e pagamentos pendentes na fila de sincronização para o cálculo de status
          final pendingItemsQueue = _itemAccountRepository.localDataSource.get('sync_queue_${_itemAccountRepository.tableName}_$userId') as List? ?? [];
          final pendingPaymentsQueue = _paymentRepository.localDataSource.get('sync_queue_${_paymentRepository.tableName}_$userId') as List? ?? [];

          final List<ItemAccountModel> pendingItems = pendingItemsQueue
              .map((e) => _itemAccountRepository.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          final List<PaymentModel> pendingPayments = pendingPaymentsQueue
              .map((e) => _paymentRepository.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          // 3. Processamento em memória (O(N) em vez de N chamadas ao banco)
          for (final client in _clients) {
            final clientAccount = allAccounts.firstWhere(
              (a) => a.clientId == client.id, 
              orElse: () => AccountModel(clientId: client.id!, status: 'LIMPA'),
            );

            if (clientAccount.id != null) {
              final items = allItems.where((it) => it.accountId == clientAccount.id).toList();
              final pItems = pendingItems.where((it) => it.accountId == clientAccount.id).toList();
              
              final payments = allPayments.where((p) => p.accountId == clientAccount.id).toList();
              final pPayments = pendingPayments.where((p) => p.accountId == clientAccount.id).toList();

              double totalDue = 0;
              for (var item in [...items, ...pItems]) {
                totalDue += item.quantity * item.unitValue;
              }

              double totalPaid = 0;
              DateTime? lastPayment;
              for (var p in [...payments, ...pPayments]) {
                totalPaid += p.value;
                if (lastPayment == null || p.date.isAfter(lastPayment)) {
                  lastPayment = p.date;
                }
              }

              String status = 'LIMPA';
              if (totalDue == 0) {
                status = 'LIMPA';
              } else if (totalPaid >= totalDue) {
                status = 'PAGA';
              } else {
                status = 'DEVENDO';
              }

              _accountStatuses[client.id!] = status;
              _lastPaymentDates[client.id!] = lastPayment;
              _clientItems[client.id!] = items.map((e) => PurchasedItemModel(
                id: e.id ?? '',
                quantity: e.quantity,
                unit: 'un', 
                description: 'Item de consumo',
                value: e.unitValue.toString(),
              )).toList();
              _clientPayments[client.id!] = payments;
            } else {
              _accountStatuses[client.id!] = 'LIMPA';
            }
          }
        }
      }
    } catch (e) {
      if (generation != _loadGeneration) return;
      debugPrint('Error loading clients and statuses: $e');
    } finally {
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

          if (!matchesSearch) return false;

          // 0: Todos, 1: Devendo, 2: Pago, 3: Limpo, 4: Atrasadas
          final status = (_accountStatuses[client.id] ?? 'LIMPA').toUpperCase();
          switch (_selectedFilterIndex) {
            case 1: // Devendo
              return status == 'DEVENDO';
            case 2: // Pago
              return status == 'PAGO' || status == 'PAGA';
            case 3: // Limpo
              return status == 'LIMPA' || status == 'LIMPO';
            case 4: // Atrasadas
              return status == 'DEVENDO';
            case 0: // Todos
            default:
              return true;
          }
        }).toList();

    filtered.sort((a, b) {
      if (_selectedFilterIndex == 4) {
        // Ordenação por data de pagamento (mais antiga primeiro)
        // Se nunca pagou, consideramos uma data muito antiga para ficar no topo
        final dateA = _lastPaymentDates[a.id] ?? DateTime(1900);
        final dateB = _lastPaymentDates[b.id] ?? DateTime(1900);
        
        final comparison = dateA.compareTo(dateB);
        return _ascendingOrder ? comparison : -comparison;
      }

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
    final userId = currentUserId(_supabaseClient);
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
    final userId = currentUserId(_supabaseClient);
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

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
