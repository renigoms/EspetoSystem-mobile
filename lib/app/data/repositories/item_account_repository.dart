import 'package:espetosystem/app/data/models/item_account_model.dart';
import 'package:espetosystem/app/data/services/base_data_source.dart';
import 'package:espetosystem/app/data/services/network_info.dart';
import 'package:espetosystem/app/data/repositories/base_repository.dart';

class ItemAccountRepository extends BaseRepository<ItemAccountModel> {
  ItemAccountRepository({
    required IBaseRemoteDataSource remoteDataSource,
    required IBaseLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : super(
          remoteDataSource: remoteDataSource,
          localDataSource: localDataSource,
          networkInfo: networkInfo,
          tableName: 'item_account',
          cacheKey: 'cached_item_account',
        );

  @override
  ItemAccountModel fromJson(Map<String, dynamic> json) => ItemAccountModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(ItemAccountModel model) => model.toJson();
  
  Future<List<ItemAccountModel>> getByAccountId(String accountId) async {
    final results = await remoteDataSource.fetchWithFilter(tableName, 'account_id', accountId);
    return results.map((e) => fromJson(e)).toList();
  }
}
