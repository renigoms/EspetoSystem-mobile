import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:espetosystem/app/data/services/base_data_source.dart';
import 'package:espetosystem/app/data/services/network_info.dart';
import 'package:espetosystem/app/data/repositories/base_repository.dart';

class PaymentRepository extends BaseRepository<PaymentModel> {
  PaymentRepository({
    required IBaseRemoteDataSource remoteDataSource,
    required IBaseLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : super(
          remoteDataSource: remoteDataSource,
          localDataSource: localDataSource,
          networkInfo: networkInfo,
          tableName: 'payment',
          cacheKey: 'cached_payment',

        );

  @override
  PaymentModel fromJson(Map<String, dynamic> json) => PaymentModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(PaymentModel model) => model.toJson();
}
