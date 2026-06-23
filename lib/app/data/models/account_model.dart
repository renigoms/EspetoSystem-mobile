class AccountModel {
  final String? id;
  final String clientId;
  final DateTime createdAt;
  final String status;
  final bool active;

  AccountModel({
    this.id,
    required this.clientId,
    DateTime? createdAt,
    this.status = 'LIMPA',
    this.active = true,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      clientId: json['client_id'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      status: json['status'] ?? 'LIMPA',
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'client_id': clientId,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'active': active,
    };
  }
}
