import 'package:espetosystem/app/data/models/account_model.dart';
import 'package:espetosystem/app/data/models/address_model.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:espetosystem/app/data/repositories/account_repository.dart';
import 'package:espetosystem/app/data/repositories/base_repository.dart';
import 'package:flutter/foundation.dart';

class ClientRepository extends BaseRepository<ClientModel> {
  final AccountRepository accountRepository;

  ClientRepository({
    required super.remoteDataSource,
    required super.localDataSource,
    required super.networkInfo,
    required this.accountRepository,
  }) : super(tableName: 'client', cacheKey: 'cached_client');

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
        return _mergeClientsAndAddresses(
          clients,
          cachedAddrs?.cast<Map<String, dynamic>>() ?? [],
        );
      }
    } else {
      final cachedAddrs = localDataSource.get(userAddrCacheKey) as List?;
      return _mergeClientsAndAddresses(
        clients,
        cachedAddrs?.cast<Map<String, dynamic>>() ?? [],
      );
    }
  }

  List<ClientModel> _mergeClientsAndAddresses(
    List<ClientModel> clients,
    List<Map<String, dynamic>> addrs,
  ) {
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
    debugPrint(
      'DEBUG: saveClient called for client ID: ${client.id}. Name: ${client.name}',
    );

    // 1. Save the client first
    final savedClient = await saveForUser(client, userId);
    debugPrint(
      'DEBUG: Client saved. Result ID: ${savedClient?.id}, Name: ${savedClient?.name}',
    );

    if (savedClient != null) {
      // Create account for the new client if it doesn't have an ID (new client)
      if (client.id == null) {
        debugPrint('DEBUG: Client is new. Creating Account.');
        try {
          await accountRepository.saveForUser(
            AccountModel(clientId: savedClient.id!, status: 'LIMPA'),
            userId,
          );
        } catch (e) {
          debugPrint(
            'DEBUG: Error creating account for client ${savedClient.id}: $e',
          );
        }
      }

      if (client.address != null) {
        debugPrint(
          'DEBUG: Processing Address for client. Address ID: ${client.address!.id}',
        );
        // 2. Prepare address data with the new client ID
        final addressData = client.address!.toJson();
        addressData['client_id'] = savedClient.id;

        try {
          if (await networkInfo.isConnected) {
            debugPrint('DEBUG: Online. Upserting address to Supabase.');
            // 3. Save to remote
            final savedAddrMap = await remoteDataSource.upsert(
              'address',
              addressData,
            );
            debugPrint('DEBUG: Address saved to Supabase successfully.');

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
          } else {
            debugPrint(
              'DEBUG: Offline. Returning client with provided address.',
            );
            return ClientModel(
              id: savedClient.id,
              userId: savedClient.userId,
              name: savedClient.name,
              description: savedClient.description,
              phoneNumber: savedClient.phoneNumber,
              cpf: savedClient.cpf,
              photoPath: savedClient.photoPath,
              address: AddressModel.fromJson(
                addressData,
              ), // Returns with client_id updated
            );
          }
        } catch (e) {
          debugPrint(
            'DEBUG: Error saving address for client ${savedClient.id}: $e',
          );
          // If address fails remote save, still return it so the UI updates
          return ClientModel(
            id: savedClient.id,
            userId: savedClient.userId,
            name: savedClient.name,
            description: savedClient.description,
            phoneNumber: savedClient.phoneNumber,
            cpf: savedClient.cpf,
            photoPath: savedClient.photoPath,
            address: AddressModel.fromJson(addressData),
          );
        }
      }
    }

    debugPrint('DEBUG: Returning saved client.');
    return savedClient;
  }

  Future<void> deleteClient(String clientId, String userId) async {
    // 1. Delete client (should cascade to address if set up in DB, but we handle local here)
    await deleteById(clientId, userId);

    // 2. Delete address from local cache
    final addressCacheKey = 'cached_address_$userId';
    final cachedAddresses = localDataSource.get(addressCacheKey);
    if (cachedAddresses is List) {
      final list =
          cachedAddresses.where((item) {
            if (item is Map) {
              return item['client_id'] != clientId;
            }
            return true;
          }).toList();
      await localDataSource.save(addressCacheKey, list);
    }

    // Note: Remote cascade delete should be handled by Supabase (ON DELETE CASCADE)
    // If not, we would need to delete items, accounts, and addresses manually here.
  }
}
