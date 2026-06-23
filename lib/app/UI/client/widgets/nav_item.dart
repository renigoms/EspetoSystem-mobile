import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.disabled = false, // Nova propriedade
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSecondary.withValues(alpha: 0.74);
    
    // Se estiver desativado, usamos uma opacidade ainda menor
    final Color iconColor = disabled 
        ? mutedColor.withValues(alpha: 0.3) 
        : (selected ? Colors.white : mutedColor);
        
    final Color labelColor = disabled 
        ? mutedColor.withValues(alpha: 0.3) 
        : (selected ? theme.colorScheme.onSurface : mutedColor);

    return SizedBox(
      width: 100,
      child: InkWell(
        onTap: disabled ? null : onTap, // Bloqueia o clique se estiver desativado
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
                    (selected && !disabled) ? theme.colorScheme.tertiary : Colors.transparent,
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
