import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The large dark-green hero card showing the total number of sites
/// registered, the delta for today, and three mini-stats.
///
/// Fully data-driven so it can be reused for other summary metrics too.
class TotalSitesCard extends StatelessWidget {
  final int total;
  final int deltaToday;
  final int today;
  final int thisWeek;
  final int villages;

  const TotalSitesCard({
    super.key,
    required this.total,
    required this.deltaToday,
    required this.today,
    required this.thisWeek,
    required this.villages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Sites Registered',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            '$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 14),
              const SizedBox(width: 4),
              Text(
                '+$deltaToday today',
                style: const TextStyle(color: Colors.greenAccent, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStat(icon: Icons.calendar_today_outlined, label: 'Today', value: '$today'),
              _MiniStat(icon: Icons.access_time, label: 'This Week', value: '$thisWeek'),
              _MiniStat(icon: Icons.location_on_outlined, label: 'Villages', value: '$villages'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
