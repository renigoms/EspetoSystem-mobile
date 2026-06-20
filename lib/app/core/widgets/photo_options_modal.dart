import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Future<void> showPhotoOptionsModal({
  required BuildContext context,
  required VoidCallback onCameraTap,
  required VoidCallback onGalleryTap,
  VoidCallback? onRemoveTap,
}) async {
  final theme = Theme.of(context);
  await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/camera.svg',
                width: 24,
                height: 24,
              ),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.of(context).pop();
                onCameraTap();
              },
            ),
            ListTile(
              leading: Icon(
                LucideIcons.image,
                color: theme.colorScheme.onSurface,
              ),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.of(context).pop();
                onGalleryTap();
              },
            ),
            if (onRemoveTap != null)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Remover foto',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onRemoveTap();
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}
