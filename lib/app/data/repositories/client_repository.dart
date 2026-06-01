import 'package:flutter/foundation.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:espetosystem/app/data/models/address_model.dart';
import 'package:espetosystem/app/data/services/base_data_source.dart';
import 'package:espetosystem/app/data/services/network_info.dart';
import 'package:espetosystem/app/data/repositories/base_repository.dart';

class ClientRepository extends BaseRepository<ClientModel> {
  ClientRepository({
    required IBaseRemoteDataSource remoteDataSource,
    required IBaseLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : super(
         remoteDataSource: remoteDataSource,
         localDataSource: localDataSource,
         networkInfo: networkInfo,
         tableName: 'client',
         cacheKey: 'cached_client',
       );

  @override
  ClientModel fromJson(Map<String, dynamic> json) => ClientModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(ClientModel model) => model.toJson();

  // Custom method for Client specific logic if needed
  Future<List<ClientModel>> getClients(String userId) async {
    final clients = await getAllForUser(userId);
    final userAddrCacheKey = 'cached_address_$userId';

    if (await networkInfo.isConnected) {
      final ids = clients.where((c) => c.id != null).map((c) => c.id!).toList();
      if (ids.isEmpty) return clients;

      try {
        final List<Map<String, dynamic>> addrs = await remoteDataSource
            .fetchWhereIn('address', 'client_id', ids);
        
        // Save address to user-specific cache
        await localDataSource.save(userAddrCacheKey, addrs);
        
        return _mergeClientsAndAddresses(clients, addrs);
      } catch (e) {
        debugPrint('Error fetching address from remote: $e');
        final cachedAddrs = localDataSource.get(userAddrCacheKey) as List?;
        return _mergeClientsAndAddresses(clients, cachedAddrs?.cast<Map<String, dynamic>>() ?? []);
      }
    } else {
      final cachedAddrs = localDataSource.get(userAddrCacheKey) as List?;
      return _mergeClientsAndAddresses(clients, cachedAddrs?.cast<Map<String, dynamic>>() ?? []);
    }
  }

  List<ClientModel> _mergeClientsAndAddresses(List<ClientModel> clients, List<Map<String, dynamic>> addrs) {
    final Map<String, Map<String, dynamic>> addrByClient = {
      for (final a in addrs) (a['client_id'] ?? '').toString(): a,
    };

    return clients.map((c) {
      final addrData = c.id != null ? addrByClient[c.id] : null;
      if (addrData != null) {
        return ClientModel(
          id: c.id,
          userId: c.userId,
          name: c.name,
          description: c.description,
          phoneNumber: c.phoneNumber,
          cpf: c.cpf,
          photoPath: c.photoPath,
          address: AddressModel.fromJson(addrData),
        );
      }
      return c;
    }).toList();
  }

  Future<ClientModel?> saveClient(ClientModel client, String userId) async {
    // 1. Save the client first
    final savedClient = await saveForUser(client, userId);

    if (savedClient != null && client.address != null) {
      // 2. Prepare address data with the new client ID
      final addressData = client.address!.toJson();
      addressData['client_id'] = savedClient.id;

      try {
        if (await networkInfo.isConnected) {
          // 3. Save to remote
          final savedAddrMap = await remoteDataSource.upsert('address', addressData);

          // 4. Return client with the saved address (including its new ID)
          return ClientModel(
            id: savedClient.id,
            userId: savedClient.userId,
            name: savedClient.name,
            description: savedClient.description,
            phoneNumber: savedClient.phoneNumber,
            cpf: savedClient.cpf,
            photoPath: savedClient.photoPath,
            address: AddressModel.fromJson(savedAddrMap),
          );
        }
      } catch (e) {
        debugPrint('Error saving address for client ${savedClient.id}: $e');
      }
    }

    return savedClient;
  }
}
