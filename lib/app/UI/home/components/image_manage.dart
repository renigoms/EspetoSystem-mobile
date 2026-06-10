import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> updateProfilePhoto(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  try {
    // 1. Seleciona a imagem da galeria
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512, // Limita o tamanho para performance
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      // Nota: Para um app de produção, você faria o upload da imagem
      // para o Supabase Storage aqui e obteria a URL pública.
      // Como estamos focados na lógica de metadados agora,
      // vamos simular o salvamento de uma URL ou path.

      // TODO: Implementar upload para Supabase Storage se necessário.
      // Por enquanto, atualizamos apenas se tivéssemos a URL.

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidade de upload de foto em desenvolvimento.'),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao selecionar foto: $e')));
    }
  }
}
