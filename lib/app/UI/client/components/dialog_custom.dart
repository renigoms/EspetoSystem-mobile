import 'package:espetosystem/app/UI/client/widgets/confirm_dialog_widget.dart';
import 'package:flutter/material.dart';

Future<bool?> confirmDialog(
  BuildContext context,
  ThemeData theme,
) async => await showDialog<bool>(
  context: context,
  builder: (ctx) => ConfirmDialogWidget(theme: theme),
  // Dialog(
  //   backgroundColor: theme.colorScheme.secondary,
  //   insetPadding: const EdgeInsets.all(24.0),
  //   shape: RoundedRectangleBorder(
  //     borderRadius: BorderRadius.circular(16.0),
  //   ),
  //   child: Container(
  //     constraints: const BoxConstraints(maxWidth: 400),
  //     padding: const EdgeInsets.all(24.0),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Excluir cliente',
  //           style: theme.textTheme.titleMedium?.copyWith(
  //             color: Colors.white,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 16.0),
  //         Text(
  //           'Tem certeza que deseja excluir este cliente? Esta ação não pode ser desfeita.',
  //           style: theme.textTheme.bodyMedium?.copyWith(
  //             color: Colors.white70,
  //           ),
  //         ),
  //         const SizedBox(height: 24.0),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.end,
  //           children: [
  //             TextButton(
  //               onPressed: () => Navigator.of(ctx).pop(false),
  //               child: Text(
  //                 'Cancelar',
  //                 style: TextStyle(
  //                   color: theme.colorScheme.onSurface.withValues(
  //                     alpha: 0.7,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 8),
  //             ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: theme.colorScheme.error,
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8.0),
  //                 ),
  //               ),
  //               onPressed: () => Navigator.of(ctx).pop(true),
  //               child: const Text(
  //                 'Excluir',
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   ),
  // ),
);
