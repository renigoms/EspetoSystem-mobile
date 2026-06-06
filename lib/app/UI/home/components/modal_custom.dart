import 'package:espetosystem/app/UI/home/view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

Future<void> openPhotoOptions(BuildContext context) async =>
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        final theme = Theme.of(context);
        final photoPath = context.watch<HomeViewModel>().photoPath;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: SvgPicture.asset(
                  'assets/icons/camera.svg',
                  width: 24,
                  height: 24,
                ),
                title: const Text('Tirar foto'),
                onTap: () async {
                  final viewModel = context.read<HomeViewModel>();
                  Navigator.of(context).pop();
                  await _pickPhoto(viewModel, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.image),
                title: const Text('Escolher da galeria'),
                onTap: () async {
                  final viewModel = context.read<HomeViewModel>();
                  Navigator.of(context).pop();
                  await _pickPhoto(viewModel, ImageSource.gallery);
                },
              ),
              if (photoPath != null)
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
                    final viewModel = context.read<HomeViewModel>();
                    Navigator.of(context).pop();
                    viewModel.photoPathAnulated();
                  },
                ),
            ],
          ),
        );
      },
    );
