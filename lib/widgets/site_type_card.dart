import 'package:flutter/material.dart';
import '../models/site.dart';
import '../theme/app_theme.dart';

/// Small card in the "By Site Type" row: icon badge, count, label and
/// percentage of the total.
class SiteTypeCard extends StatelessWidget {
  final SiteType type;
  final int count;
  final double percentage;

  const SiteTypeCard({
    super.key,
    required this.type,
    required this.count,
    required this.percentage,
  });

  ({IconData icon, Color bg, Color fg}) get _style {
    switch (type) {
      case SiteType.house:
        return (icon: Icons.home_outlined, bg: AppColors.houseBg, fg: AppColors.houseFg);
      case SiteType.business:
        return (icon: Icons.storefront_outlined, bg: AppColors.businessBg, fg: AppColors.businessFg);
      case SiteType.church:
        return (icon: Icons.church_outlined, bg: AppColors.churchBg, fg: AppColors.churchFg);
      case SiteType.school:
        return (icon: Icons.school_outlined, bg: AppColors.schoolBg, fg: AppColors.schoolFg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 18, backgroundColor: s.bg, child: Icon(s.icon, color: s.fg, size: 18)),
          const SizedBox(height: 10),
          Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(type.label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(20)),
            child: Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(color: s.fg, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
