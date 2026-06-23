import 'package:espetosystem/app/UI/authentication/view_models/auth_view_model.dart';
import 'package:espetosystem/app/core/widgets/photo_options_modal.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

Future<void> updateProfilePhoto(BuildContext context) async {
  final authViewModel = context.read<AuthViewModel>();
  final hasAvatar = authViewModel.currentUser?.userMetadata?['avatar_url'] != null;

  await showPhotoOptionsModal(
    context: context,
    onCameraTap: () => _handleImagePick(context, ImageSource.camera),
    onGalleryTap: () => _handleImagePick(context, ImageSource.gallery),
    onRemoveTap: hasAvatar ? () => _removePhoto(context) : null,
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
      final String publicUrl = await authViewModel.uploadAvatar(
        userId,
        image.path,
      );

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar foto: $e')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao remover foto: $e')));
    }
  }
}
