import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoLine extends StatelessWidget {
  const InfoLine({
    super.key,
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: GoogleFonts.roboto(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: value),
        ],
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.roboto(
        color: theme.colorScheme.onSurface,
        fontSize: 14,
        height: 1.18,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
