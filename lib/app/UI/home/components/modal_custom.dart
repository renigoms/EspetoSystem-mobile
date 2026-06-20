import 'package:espetosystem/app/UI/home/view_models/home_view_model.dart';
import 'package:espetosystem/app/UI/home/widgets/client_form_sheet.dart';
import 'package:espetosystem/app/core/widgets/photo_options_modal.dart';
import 'package:espetosystem/app/data/models/client_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

Future<void> _pickPhoto(HomeViewModel homeViewModel, ImageSource source) async {
  final picked = await ImagePicker().pickImage(
    source: source,
    imageQuality: 85,
  );

  if (picked == null) {
    return;
  }

  homeViewModel.setPhotoPath(picked.path);
}

Future<void> openPhotoOptions(BuildContext context) async {
  final homeViewModel = context.read<HomeViewModel>();
  await showPhotoOptionsModal(
    context: context,
    onCameraTap: () => _pickPhoto(homeViewModel, ImageSource.camera),
    onGalleryTap: () => _pickPhoto(homeViewModel, ImageSource.gallery),
    onRemoveTap: homeViewModel.photoPath != null ? () => homeViewModel.photoPathAnulated() : null,
  );
}

Future<ClientModel?> create(BuildContext context, ThemeData theme) async =>
    await showModalBottomSheet<ClientModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext context) {
        return const ClientFormSheet();
      },
    );
