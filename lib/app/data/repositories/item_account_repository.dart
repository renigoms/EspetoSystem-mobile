import 'package:espetosystem/app/data/models/item_account_model.dart';
import 'package:espetosystem/app/data/repositories/base_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemAccountRepository extends BaseRepository<ItemAccountModel> {
  ItemAccountRepository({
    required super.remoteDataSource,
    required super.localDataSource,
    required super.networkInfo,
  }) : super(tableName: 'item_account', cacheKey: 'cached_item_account');

  @override
  ItemAccountModel fromJson(Map<String, dynamic> json) =>
      ItemAccountModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(ItemAccountModel model) => model.toJson();

  Future<List<ItemAccountModel>> getByAccountId(String accountId, String userId) async {
    final userCacheKey = 'cached_item_account_$userId';
    if (await networkInfo.isConnected) {
      try {
        final results = await remoteDataSource.fetchWithFilter(
          tableName,
          'account_id',
          accountId,
        );
        
        // Update the global cache for this user with these items
        final List<ItemAccountModel> items = results.map((e) => fromJson(e)).toList();
        for (final item in items) {
          await upsertCachedUserModel(userCacheKey, toJson(item));
        }

        return items;
      } catch (e) {
        debugPrint('Error fetching items for account $accountId: $e');
      }
    }
    
    // Fallback para cache local com a chave correta
    final cached = await getCachedList(userCacheKey); 
    return cached.where((item) => item.accountId == accountId).toList();
  }

  Future<List<ItemAccountModel>> getItemsByAccountIds(List<String> accountIds, String userId) async {
    final userCacheKey = 'cached_item_account_$userId';

    if (await networkInfo.isConnected) {
      try {
        final List<Map<String, dynamic>> data = await remoteDataSource
            .fetchWhereIn(tableName, 'account_id', accountIds);

        await localDataSource.save(userCacheKey, data);
        return data.map((e) => fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error fetching items for user $userId: $e');
        return getCachedList(userCacheKey);
      }
    } else {
      return getCachedList(userCacheKey);
    }
  }
}
