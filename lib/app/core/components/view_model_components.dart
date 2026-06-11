import 'package:espetosystem/app/data/models/account_model.dart';
import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:espetosystem/app/data/models/purchased_item_model.dart';
import 'package:espetosystem/app/data/repositories/account_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String? currentUserId(SupabaseClient supabaseClient) =>
    supabaseClient.auth.currentSession?.user.id ??
    supabaseClient.auth.currentUser?.id;

double totalDebtForClient(
  String clientId,
  Map<String, List<PurchasedItemModel>> clientItems,
  Map<String, List<PaymentModel>> clientPayments,
) {
  final items = clientItems[clientId] ?? [];
  final payments = clientPayments[clientId] ?? [];

  final itemsTotal = items.fold(0.0, (total, item) {
    final double unitValue =
        double.tryParse(
          item.value
              .replaceAll('R\$ ', '')
              .replaceAll('.', '')
              .replaceAll(',', '.'),
        ) ??
        0;
    return total + (item.quantity * unitValue);
  });

  final paymentsTotal = payments.fold(
    0.0,
    (total, payment) => total + payment.value,
  );

  final debt = itemsTotal - paymentsTotal;
  return debt > 0 ? debt : 0.0;
}

Future<String> getStatusIfNeeded(
  String clientId,
  String? userId,
  AccountRepository? accountRepository,
  double debt,
) async {
  if (accountRepository == null || userId == null) return '';

  final account = await accountRepository.getByClientId(clientId);

  if (account != null) {
    final newStatus = debt > 0 ? 'DEVENDO' : 'LIMPA';
    if (account.status != newStatus) {
      await accountRepository.saveForUser(
        AccountModel(id: account.id, clientId: clientId, status: newStatus),
        userId,
      );
      return newStatus;
    }
    return account.status;
  }
  return '';
}
