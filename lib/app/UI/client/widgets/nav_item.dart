import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSecondary.withValues(alpha: 0.74);
    final iconColor = selected ? Colors.white : mutedColor;
    final labelColor = selected ? theme.colorScheme.onSurface : mutedColor;

    return SizedBox(
      width: 100,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    selected ? theme.colorScheme.tertiary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                color: labelColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
