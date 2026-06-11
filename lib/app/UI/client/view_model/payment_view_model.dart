import 'package:espetosystem/app/UI/client/view_model/base_view_model.dart';
import 'package:espetosystem/app/core/components/view_model_components.dart';
import 'package:espetosystem/app/data/models/payment_model.dart';
import 'package:espetosystem/app/data/repositories/account_repository.dart';
import 'package:espetosystem/app/data/repositories/payment_repository.dart';
import 'package:flutter/material.dart';

class PaymentViewModel extends BaseViewModel {
  final AccountRepository? _accountRepository;
  final PaymentRepository? _paymentRepository;
  PaymentViewModel(
    super.supabaseClient,
    this._accountRepository,
    this._paymentRepository,
  );

  Future<void> addPaymentToClientAccount(
    String clientId,
    Map<String, dynamic> paymentData,
  ) async {
    final userId = currentUserId(supabaseClient);
    debugPrint(
      'DEBUG PAYMENT: Starting addPaymentToClientAccount for client: $clientId',
    );
    if (userId == null ||
        _accountRepository == null ||
        _paymentRepository == null) {
      debugPrint('DEBUG PAYMENT: Missing repositories or userId');
      return;
    }

    try {
      final account = await _accountRepository.getByClientId(clientId);
      if (account?.id == null) {
        debugPrint('DEBUG PAYMENT: Account not found for client: $clientId');
        return;
      }
      debugPrint('DEBUG PAYMENT: Found account: ${account!.id}');

      final double valor = paymentData['valor'] as double;
      debugPrint('DEBUG PAYMENT: Payment value to save: $valor');

      final paymentModel = PaymentModel(
        accountId: account.id!,
        date: DateTime.now(),
        value: valor,
      );

      debugPrint('DEBUG PAYMENT: Calling paymentRepository.saveForUser');
      final payment = await _paymentRepository.saveForUser(
        paymentModel,
        userId,
      );

      if (payment != null) {
        debugPrint(
          'DEBUG PAYMENT: Payment saved successfully (local or remote). ID: ${payment.id}',
        );
        final currentPayments = clientPayments[clientId] ?? [];
        clientPayments[clientId] = [...currentPayments, payment];

        // Recalculate debt and update status if necessary
        debugPrint('DEBUG PAYMENT: Updating account status and debt.');
        accountStatuses[clientId] = await getStatusIfNeeded(
          clientId,
          currentUserId(supabaseClient),
          _accountRepository,
          totalDebtForClient(clientId, clientItems, clientPayments),
        );
        notifyListeners();
        debugPrint('DEBUG PAYMENT: UI notified.');
      } else {
        debugPrint(
          'DEBUG PAYMENT: paymentRepository.saveForUser returned null!',
        );
        // Fallback para offline-first imediato na UI
        final fallbackPayment = PaymentModel(
          accountId: account.id!,
          date: DateTime.now(),
          value: valor,
        );
        final currentPayments = clientPayments[clientId] ?? [];
        clientPayments[clientId] = [...currentPayments, fallbackPayment];
        accountStatuses[clientId] = await getStatusIfNeeded(
          clientId,
          currentUserId(supabaseClient),
          _accountRepository,
          totalDebtForClient(clientId, clientItems, clientPayments),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('DEBUG PAYMENT: Critical error adding payment: $e');
    }
  }
}
