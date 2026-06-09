import 'package:supabase_flutter/supabase_flutter.dart';

extension UserAvatarExtension on User {
  String? get avatarUrl {
    final metadata = userMetadata;
    final rawUrl =
        metadata?['avatar_url'] ??
        metadata?['picture'] ??
        metadata?['photo_url'] ??
        metadata?['avatar'] ??
        metadata?['image_url'];

    if (rawUrl is String && rawUrl.isNotEmpty) return rawUrl;
    return null;
  }

  String? get displayName {
    final metadata = userMetadata;
    final value =
        (metadata?['full_name'] ?? metadata?['name'] ?? email ?? 'Usuário')
            .toString()
            .trim();

    return value.isEmpty ? 'Usuário' : value;
  }
}
