import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:espetosystem/app/data/models/account_model.dart';
import 'package:espetosystem/app/data/repositories/account_repository.dart';
import 'package:espetosystem/app/data/repositories/client_repository.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeViewModel extends ChangeNotifier {
  final ClientRepository? _clientRepository;
  final AccountRepository? _accountRepository;
  final SupabaseClient _supabaseClient;
  StreamSubscription<AuthState>? _authStateSubscription;
  int _loadGeneration = 0;
  final List<ClientModel> _pendingClients = <ClientModel>[];

  HomeViewModel({
    AccountRepository? accountRepository,
    ClientRepository? clientRepository,
    required SupabaseClient supabaseClient,
  }) : _accountRepository = accountRepository,
       _clientRepository = clientRepository,
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

  String? get _currentUserId =>
      _supabaseClient.auth.currentSession?.user.id ??
      _supabaseClient.auth.currentUser?.id;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<ClientModel> _clients = <ClientModel>[];

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
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
