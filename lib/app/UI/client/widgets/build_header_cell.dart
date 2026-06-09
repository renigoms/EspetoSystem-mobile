import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuildHeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const BuildHeaderCell(this.label, this.flex, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: GoogleFonts.roboto(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
