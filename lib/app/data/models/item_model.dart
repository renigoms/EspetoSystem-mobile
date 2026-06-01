class ItemModel {
  final String? id;
  final String description;
  final String measurementUnit;

  ItemModel({
    this.id,
    required this.description,
    this.measurementUnit = 'UND',
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      description: json['description'] ?? '',
      measurementUnit: json['measurement_unit'] ?? 'UND',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'description': description,
      'measurement_unit': measurementUnit,
    };
  }
}
