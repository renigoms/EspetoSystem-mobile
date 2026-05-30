class PaymentModel {
  final String? id;
  final String accountId;
  final DateTime paymentDate;
  final int value;

  PaymentModel({
    this.id,
    required this.accountId,
    required this.paymentDate,
    required this.value,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      accountId: json['account_id'] ?? '',
      paymentDate: DateTime.parse(json['payment_date'] ?? DateTime.now().toIso8601String()),
      value: json['value'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'account_id': accountId,
      'payment_date': paymentDate.toIso8601String(),
      'value': value,
    };
  }
}
