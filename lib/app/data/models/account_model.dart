class AccountModel {
  final String? id;
  final String clientId;
  final DateTime createdAt;
  final String status;

  AccountModel({
    this.id,
    required this.clientId,
    DateTime? createdAt,
    this.status = 'LIMPA',
  }) : createdAt = createdAt ?? DateTime.now();

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      clientId: json['client_id'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      status: json['status'] ?? 'LIMPA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'client_id': clientId,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }
}
