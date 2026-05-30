import 'address_model.dart';

class ClientModel {
  final String? id;
  final String name;
  final String description;
  final String phoneNumber;
  final String cpf;
  final AddressModel? address;

  ClientModel({
    this.id,
    required this.name,
    required this.description,
    required this.phoneNumber,
    required this.cpf,
    this.address,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      cpf: json['cpf'] ?? '',
      address: json['address'] != null ? AddressModel.fromJson(json['address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'phone_number': phoneNumber,
      'cpf': cpf,
    };
  }
}
