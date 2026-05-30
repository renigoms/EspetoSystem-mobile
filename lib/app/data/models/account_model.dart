class AccountModel {
  final String? id;
  final String clientId;
  final DateTime? lastPurchaseDate;

  AccountModel({
    this.id,
    required this.clientId,
    this.lastPurchaseDate,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      clientId: json['client_id'] ?? '',
      lastPurchaseDate: json['last_purchase_date'] != null 
          ? DateTime.parse(json['last_purchase_date']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'client_id': clientId,
      'last_purchase_date': lastPurchaseDate?.toIso8601String(),
    };
  }
}
