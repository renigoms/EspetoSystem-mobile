import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuildHeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const BuildHeaderCell(this.label, {super.key, this.flex = 0});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.roboto(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
