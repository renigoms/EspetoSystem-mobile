import 'address_model.dart';

class ClientModel {
  final String? id;
  final String? userId;
  final String name;
  final String description;
  final String phoneNumber;
  final String cpf;
  final String? photoPath;
  final AddressModel? address;

  ClientModel({
    this.id,
    this.userId,
    required this.name,
    required this.description,
    required this.phoneNumber,
    required this.cpf,
    this.photoPath,
    this.address,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      cpf: json['cpf'] ?? '',
      photoPath: json['photo_path'],
      address:
          json['address'] != null
              ? AddressModel.fromJson(json['address'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'name': name,
      'description': description,
      'phone_number': phoneNumber,
      'cpf': cpf,
      if (photoPath != null) 'photo_path': photoPath,
    };
  }
}
