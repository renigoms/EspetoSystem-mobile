import 'package:espetosystem/app/data/models/account_model.dart';
import 'package:espetosystem/app/data/repositories/base_repository.dart';

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

  Future<AccountModel?> getByClientId(String clientId) async {
    final results = await remoteDataSource.fetchWithFilter(
      tableName,
      'client_id',
      clientId,
    );
    return results.isNotEmpty ? fromJson(results.first) : null;
  }
}
