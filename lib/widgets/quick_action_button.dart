import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A single tile in the "Quick Actions" grid. Can be rendered as a
/// highlighted (filled) primary action or a plain outlined action.
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlighted;
  final VoidCallback? onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = highlighted ? AppColors.primary : AppColors.surface;
    final fg = highlighted ? Colors.white : AppColors.primary;
    final subFg = highlighted ? Colors.white70 : AppColors.textSecondary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: highlighted ? null : Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              highlighted
                  ? CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(icon, color: AppColors.primary, size: 18),
                    )
                  : Icon(icon, color: fg, size: 26),
              const SizedBox(height: 10),
              Text(title,
                  style: TextStyle(
                      color: highlighted ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: subFg, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
