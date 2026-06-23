import 'dart:io';
import 'package:flutter/material.dart';

class ClientAvatar extends StatelessWidget {
  const ClientAvatar({super.key, required this.name, this.photoPath, this.size = 46});

  final String name;
  final String? photoPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials =
        name
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0])
            .join()
            .toUpperCase();

    final fallback = Center(
      child: Text(
        initials.isEmpty ? 'U' : initials,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final image =
        photoPath != null && photoPath!.isNotEmpty
            ? Image.file(
              File(photoPath!),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            )
            : fallback;

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.12),
        child: image,
      ),
    );
  }
}
