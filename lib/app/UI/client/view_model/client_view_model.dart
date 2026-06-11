import 'package:espetosystem/app/UI/client/view_model/base_view_model.dart';
import 'package:espetosystem/app/core/components/view_model_components.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:espetosystem/app/data/repositories/account_repository.dart';
import 'package:espetosystem/app/data/repositories/client_repository.dart';
import 'package:espetosystem/app/data/repositories/payment_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientViewModel extends BaseViewModel {
  final ClientRepository? _clientRepository;
  final SupabaseClient _supabaseClient;

  ClientViewModel(this._clientRepository, this._supabaseClient)
    : super(_supabaseClient) {
    clients.clear();
    isLoading = false;
  }

  Future<ClientModel?> updateClient(ClientModel client) async {
    final userId = currentUserId(_supabaseClient);
    if (_clientRepository == null || userId == null) return null;

    final saved = await _clientRepository.saveClient(client, userId);
    if (saved != null) {
      final index = clients.indexWhere((c) => c.id == saved.id);
      if (index != -1) {
        clients[index] = saved;
      } else {
        clients.add(saved);
      }
      notifyListeners();
    }
    return saved;
  }

  Future<void> deleteClient(String clientId) async {
    final userId = currentUserId(_supabaseClient);
    if (_clientRepository == null || userId == null) return;

    await _clientRepository.deleteClient(clientId, userId);
    clients.removeWhere((c) => c.id == clientId);
    accountStatuses.remove(clientId);
    clientItems.remove(clientId);
    notifyListeners();
  }
}
