import 'package:espetosystem/app/data/models/item_model.dart';
import 'package:espetosystem/app/data/repositories/base_repository.dart';

class ItemRepository extends BaseRepository<ItemModel> {
  ItemRepository({
    required super.remoteDataSource,
    required super.localDataSource,
    required super.networkInfo,
  }) : super(tableName: 'item', cacheKey: 'cached_item');

  @override
  ItemModel fromJson(Map<String, dynamic> json) => ItemModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(ItemModel model) => model.toJson();
}
