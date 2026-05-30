import 'package:espetosystem/app/UI/home/widgets/user_profile_avatar.dart';
import 'package:espetosystem/app/core/themes/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:espetosystem/app/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppBarCustom extends StatelessWidget {
  final ThemeData theme;
  const AppBarCustom({super.key, required this.theme});

  String? _avatarUrl(User? user) {
    final metadata = user?.userMetadata;
    final rawUrl =
        metadata?['avatar_url'] ??
        metadata?['picture'] ??
        metadata?['photo_url'] ??
        metadata?['avatar'] ??
        metadata?['image_url'];

    if (rawUrl is String && rawUrl.isNotEmpty) {
      return rawUrl;
    }

    return null;
  }

  String _fallbackLabel(User? user) {
    final metadata = user?.userMetadata;
    final name =
        (metadata?['full_name'] ?? metadata?['name'] ?? user?.email ?? '')
            .toString()
            .trim();

    if (name.isEmpty) {
      return 'U';
    }

    final parts = name.split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first : name;
    final last = parts.length > 1 ? parts.last : '';
    return (first.isNotEmpty ? first[0] : '') +
        (last.isNotEmpty ? last[0] : '');
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeViewModel>().themeMode;
    final authRepository = context.read<AuthRepository>();
    final currentUser = authRepository.supabaseClient.auth.currentUser;
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 75,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 17,
            children: [
              Image.asset('assets/images/logo.png', width: 31, height: 41),
              Row(
                children: [
                  Text(
                    "Espeto",
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  Text(
                    "System",
                    style: TextStyle(color: theme.colorScheme.tertiary),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserProfileAvatar(
                size: 34,
                avatarUrl: _avatarUrl(currentUser),
                fallbackLabel: _fallbackLabel(currentUser),
                onTap: () => context.push('/home/personal-info'),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => context.push('/home/settings'),
                child: SvgPicture.asset(
                  themeMode == ThemeMode.light
                      ? 'assets/icons/settings-light.svg'
                      : 'assets/icons/settings-dark.svg',
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.primary,
    );
  }
}
