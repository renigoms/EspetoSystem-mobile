class AuthProfileModel {
  final String id; // Matches Supabase Auth User ID
  final String login;
  final String securityAnswer;
  final String role;

  AuthProfileModel({
    required this.id,
    required this.login,
    required this.securityAnswer,
    required this.role,
  });

  factory AuthProfileModel.fromJson(Map<String, dynamic> json) {
    return AuthProfileModel(
      id: json['id'],
      login: json['login'] ?? '',
      securityAnswer: json['security_answer'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'security_answer': securityAnswer,
      'role': role,
    };
  }
}
