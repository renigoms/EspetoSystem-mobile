import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:espetosystem/app/data/repositories/base_repository.dart';
import 'package:flutter/foundation.dart';

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

  Future<List<PaymentModel>> getPaymentsByAccountIds(List<String> accountIds, String userId) async {
    final userCacheKey = 'cached_payments_all_$userId';

    if (await networkInfo.isConnected) {
      try {
        final List<Map<String, dynamic>> data = await remoteDataSource
            .fetchWhereIn(tableName, 'account_id', accountIds);

        await localDataSource.save(userCacheKey, data);
        return data.map((e) => fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error fetching payments for user $userId: $e');
        return getCachedList(userCacheKey);
      }
    } else {
      return getCachedList(userCacheKey);
    }
  }
}
