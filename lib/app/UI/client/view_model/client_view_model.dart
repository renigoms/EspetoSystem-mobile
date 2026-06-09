import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:espetosystem/app/data/repositories/client_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientViewModel extends ChangeNotifier {
  final ClientRepository? _clientRepository;
  final SupabaseClient _supabaseClient;

  final List<ClientModel> _clients = <ClientModel>[];

  ClientViewModel(this._clientRepository, this._supabaseClient);

  String? get _currentUserId =>
      _supabaseClient.auth.currentSession?.user.id ??
      _supabaseClient.auth.currentUser?.id;

  Future<ClientModel?> saveClient(ClientModel client) async {
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
}
