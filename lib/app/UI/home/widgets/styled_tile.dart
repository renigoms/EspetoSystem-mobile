import 'package:flutter/material.dart';

class StyledTile extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const StyledTile({
    super.key,
    required this.theme,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: Border(
        top: BorderSide(width: 0.5, color: theme.colorScheme.onTertiary),
      ),
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              trailing ??
                  Icon(Icons.chevron_right, color: theme.colorScheme.tertiary),
            ],
          ),
        ),
      ),
    );
  }
}
