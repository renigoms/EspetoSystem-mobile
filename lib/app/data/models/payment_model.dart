class PaymentModel {
  final String? id;
  final String accountId;
  final DateTime date;
  final double value;

  PaymentModel({
    this.id,
    required this.accountId,
    required this.date,
    required this.value,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      accountId: json['account_id'] ?? '',
      date: DateTime.parse(json['date'] ?? json['payment_date'] ?? DateTime.now().toIso8601String()),
      value: (json['value'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'account_id': accountId,
      'date': date.toIso8601String(),
      'value': value,
    };
  }
}
