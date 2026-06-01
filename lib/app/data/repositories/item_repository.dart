import 'package:espetosystem/app/data/models/item_model.dart';
import 'package:espetosystem/app/data/services/base_data_source.dart';
import 'package:espetosystem/app/data/services/network_info.dart';
import 'package:espetosystem/app/data/repositories/base_repository.dart';

class ItemRepository extends BaseRepository<ItemModel> {
  ItemRepository({
    required IBaseRemoteDataSource remoteDataSource,
    required IBaseLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : super(
          remoteDataSource: remoteDataSource,
          localDataSource: localDataSource,
          networkInfo: networkInfo,
          tableName: 'item',
          cacheKey: 'cached_item',

        );

  @override
  ItemModel fromJson(Map<String, dynamic> json) => ItemModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(ItemModel model) => model.toJson();
}
