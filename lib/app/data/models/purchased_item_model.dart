class PurchasedItemModel {
  final String? id; // ID da tabela item_account necessário para delete/update
  final int quantity;
  final String unit;
  final String description;
  final String value;

  const PurchasedItemModel({
    this.id,
    required this.quantity,
    required this.unit,
    required this.description,
    required this.value,
  });
}
