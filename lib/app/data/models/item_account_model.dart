class ItemAccountModel {
  final String? id;
  final int quantity;
  final String itemId;
  final String accountId;
  final double unitValue;
  final String measurementUnit;
  final DateTime createdAt;

  ItemAccountModel({
    this.id,
    required this.quantity,
    required this.itemId,
    required this.accountId,
    required this.unitValue,
    this.measurementUnit = 'UND',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ItemAccountModel.fromJson(Map<String, dynamic> json) {
    return ItemAccountModel(
      id: json['id'],
      quantity: json['quantity'] ?? 0,
      itemId: json['item_id'] ?? '',
      accountId: json['account_id'] ?? '',
      unitValue: (json['unit_value'] ?? 0).toDouble(),
      measurementUnit: json['measurement_unit'] ?? 'UND',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'quantity': quantity,
      'item_id': itemId,
      'account_id': accountId,
      'unit_value': unitValue,
      'measurement_unit': measurementUnit,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
