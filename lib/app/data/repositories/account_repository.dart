import 'package:espetosystem/app/data/models/account_model.dart';
import 'package:espetosystem/app/data/repositories/base_repository.dart';
import 'package:flutter/foundation.dart';

class AccountRepository extends BaseRepository<AccountModel> {
  AccountRepository({
    required super.remoteDataSource,
    required super.localDataSource,
    required super.networkInfo,
  }) : super(tableName: 'account', cacheKey: 'cached_account');

  @override
  AccountModel fromJson(Map<String, dynamic> json) =>
      AccountModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(AccountModel model) => model.toJson();

  Future<AccountModel?> getByClientId(String clientId, String userId) async {
    final userCacheKey = 'cached_account_$userId';

    if (await networkInfo.isConnected) {
      try {
        final results = await remoteDataSource.fetchWithFilter(
          tableName,
          'client_id',
          clientId,
        );
        if (results.isNotEmpty) {
          final accounts = results.map((json) => fromJson(json)).toList();
          AccountModel? activeAccount;
          for (final a in accounts) {
            if (a.active) {
              activeAccount = a;
              break;
            }
          }
          if (activeAccount != null) {
            await upsertCachedUserModel(userCacheKey, toJson(activeAccount));
            return activeAccount;
          }
        }
      } catch (e) {
        debugPrint('Error fetching account for client $clientId: $e');
      }
    }
    
    // Fallback para cache usando a chave correta com userId
    final cached = await getCachedList(userCacheKey);
    return cached.cast<AccountModel?>().firstWhere(
      (a) => a?.clientId == clientId && (a?.active ?? false),
      orElse: () => null,
    );
  }

  Future<List<AccountModel>> getAccountsByClientIds(List<String> clientIds, String userId) async {
    final userCacheKey = 'cached_account_$userId';

    if (await networkInfo.isConnected) {
      try {
        final List<Map<String, dynamic>> data = await remoteDataSource
            .fetchWhereIn(tableName, 'client_id', clientIds);

        await localDataSource.save(userCacheKey, data);
        return data.map((e) => fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error fetching accounts for user $userId: $e');
        return getCachedList(userCacheKey);
      }
    } else {
      return getCachedList(userCacheKey);
    }
  }
}
