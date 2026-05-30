import '../models/client_model.dart';
import '../services/supabase_service.dart';
import '../services/local_cache_service.dart';
import '../services/network_info.dart';

class ClientRepository {
  final SupabaseService remoteDataSource;
  final LocalCacheService localDataSource;
  final NetworkInfo networkInfo;

  ClientRepository({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  static const String _cacheKey = 'cached_clients';

  Future<List<ClientModel>> getClients() async {
    if (await networkInfo.isConnected) {
      try {
        final List<Map<String, dynamic>> data = await remoteDataSource.fetchAll('clients');
        final clients = data.map((e) => ClientModel.fromJson(e)).toList();
        
        // Update cache
        await localDataSource.save(_cacheKey, data);
        
        return clients;
      } catch (e) {
        // Fallback to cache if remote fails
        return _getCachedClients();
      }
    } else {
      return _getCachedClients();
    }
  }

  Future<List<ClientModel>> _getCachedClients() async {
    final cachedData = localDataSource.get(_cacheKey);
    if (cachedData != null && cachedData is List) {
      return (cachedData).map((e) => ClientModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> saveClient(ClientModel client) async {
    if (await networkInfo.isConnected) {
      await remoteDataSource.upsert('clients', client.toJson());
      // Re-fetch or update local cache manually
    } else {
      // Store in a "to-sync" queue if offline
      // For simplicity in this example, we'll just save to local cache
      final List<ClientModel> current = await _getCachedClients();
      current.add(client);
      await localDataSource.save(_cacheKey, current.map((e) => e.toJson()).toList());
    }
  }
}
