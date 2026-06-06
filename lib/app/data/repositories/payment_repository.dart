import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:espetosystem/app/data/repositories/base_repository.dart';

class PaymentRepository extends BaseRepository<PaymentModel> {
  PaymentRepository({
    required super.remoteDataSource,
    required super.localDataSource,
    required super.networkInfo,
  }) : super(tableName: 'payment', cacheKey: 'cached_payment');

  @override
  PaymentModel fromJson(Map<String, dynamic> json) =>
      PaymentModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(PaymentModel model) => model.toJson();
}
