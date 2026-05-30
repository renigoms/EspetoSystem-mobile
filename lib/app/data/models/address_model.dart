class AddressModel {
  final String? id;
  final String street;
  final String neighborhood;
  final int number;
  final String? clientId;

  AddressModel({
    this.id,
    required this.street,
    required this.neighborhood,
    required this.number,
    this.clientId,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      street: json['street'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      number: json['number'] ?? 0,
      clientId: json['client_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'street': street,
      'neighborhood': neighborhood,
      'number': number,
      'client_id': clientId,
    };
  }
}
