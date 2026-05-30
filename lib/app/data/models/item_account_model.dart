class ItemAccountModel {
  final String? id;
  final int quantity;
  final String description;
  final String accountId;
  final double unitValue;

  ItemAccountModel({
    this.id,
    required this.quantity,
    required this.description,
    required this.accountId,
    required this.unitValue,
  });

  factory ItemAccountModel.fromJson(Map<String, dynamic> json) {
    return ItemAccountModel(
      id: json['id'],
      quantity: json['quantity'] ?? 0,
      description: json['description'] ?? '',
      accountId: json['account_id'] ?? '',
      unitValue: (json['unit_value'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'quantity': quantity,
      'description': description,
      'account_id': accountId,
      'unit_value': unitValue,
    };
  }
}
