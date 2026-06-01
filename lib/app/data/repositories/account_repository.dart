import 'package:espetosystem/app/data/models/account_model.dart';
import 'package:espetosystem/app/data/services/base_data_source.dart';
import 'package:espetosystem/app/data/services/network_info.dart';
import 'package:espetosystem/app/data/repositories/base_repository.dart';

class AccountRepository extends BaseRepository<AccountModel> {
  AccountRepository({
    required IBaseRemoteDataSource remoteDataSource,
    required IBaseLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : super(
          remoteDataSource: remoteDataSource,
          localDataSource: localDataSource,
          networkInfo: networkInfo,
          tableName: 'account',
          cacheKey: 'cached_account',

        );

  @override
  AccountModel fromJson(Map<String, dynamic> json) => AccountModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(AccountModel model) => model.toJson();
}
