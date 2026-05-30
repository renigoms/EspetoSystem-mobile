import 'package:flutter/material.dart';

class UserProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String fallbackLabel;
  final double size;
  final VoidCallback? onTap;

  const UserProfileAvatar({
    super.key,
    required this.fallbackLabel,
    required this.size,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final avatar =
        avatarUrl != null
            ? ClipOval(
              child: Image.network(
                avatarUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackContent(theme),
              ),
            )
            : _fallbackContent(theme);

    final decorated = Container(
      width: size + 12,
      height: size + 12,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(child: avatar),
    );

    if (onTap == null) return decorated;

    return GestureDetector(onTap: onTap, child: decorated);
  }

  Widget _fallbackContent(ThemeData theme) {
    final text =
        fallbackLabel.isEmpty
            ? 'U'
            : fallbackLabel
                .substring(
                  0,
                  fallbackLabel.length > 2 ? 2 : fallbackLabel.length,
                )
                .toUpperCase();

    return Container(
      width: size,
      height: size,
      color: theme.colorScheme.primaryContainer.withOpacity(0.06),
      alignment: Alignment.center,
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
