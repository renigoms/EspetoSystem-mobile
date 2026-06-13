import 'dart:io';
import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> updateProfilePhoto(BuildContext context) async {
  final authViewModel = context.read<AuthViewModel>();
  final theme = Theme.of(context);

  await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
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
              onTap: () async {
                Navigator.of(ctx).pop();
                await _handleImagePick(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Escolher da galeria'),
              onTap: () async {
                Navigator.of(ctx).pop();
                await _handleImagePick(context, ImageSource.gallery);
              },
            ),
            if (authViewModel.currentUser?.userMetadata?['avatar_url'] != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                title: Text(
                  'Remover foto',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _removePhoto(context);
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

Future<void> _handleImagePick(BuildContext context, ImageSource source) async {
  final ImagePicker picker = ImagePicker();
  final authViewModel = context.read<AuthViewModel>();

  try {
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atualizando sua foto de perfil...'),
          duration: Duration(seconds: 2),
        ),
      );

      final userId = authViewModel.currentUser?.id;
      if (userId == null) return;

      // 1. Upload e geração de URL via ViewModel (que usa o Repository)
      final String publicUrl = await authViewModel.uploadAvatar(userId, image.path);

      // 2. Atualizar o perfil (metadata do usuário)
      await authViewModel.updateProfile(avatarUrl: publicUrl);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil atualizada!')),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar foto: $e')),
      );
    }
  }
}

Future<void> _removePhoto(BuildContext context) async {
  final authViewModel = context.read<AuthViewModel>();
  try {
    await authViewModel.updateProfile(avatarUrl: null);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto removida com sucesso!')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover foto: $e')),
      );
    }
  }
}
