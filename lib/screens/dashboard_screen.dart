import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/db_helper.dart';
import '../models/site.dart';
import '../theme/app_theme.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/recent_registration_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/site_type_card.dart';
import '../widgets/total_sites_card.dart';
import '../widgets/village_progress_row.dart';
import 'register_site_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int refreshToken;
  final ValueChanged<int>? onNavigate;
  final VoidCallback? onOpenRegister;

  const DashboardScreen({
    super.key,
    this.refreshToken = 0,
    this.onNavigate,
    this.onOpenRegister,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardStats _stats = DashboardStats.empty();
  List<Site> _recent = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken!= widget.refreshToken) {
      _load();
    }
  }

  Future<void> _bootstrap() async {
    try {
      // 1. Ensure DB is open first
      await DBHelper.instance.database;
      // 2. Only then seed. If seeding fails, we still try to load
      await DBHelper.instance.seedIfEmpty().catchError((e, st) {
        debugPrint('Seed failed but continuing: $e\n$st');
      });
      await _load();
    } catch (error, stack) {
      debugPrint('Dashboard bootstrap failed: $error\n$stack');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to initialize database: ${error.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        DBHelper.instance.getDashboardStats(),
        DBHelper.instance.getAllSites(limit: 4),
      ]);

      if (!mounted) return;
      setState(() {
        _stats = results[0] as DashboardStats;
        _recent = results[1] as List<Site>;
        _loading = false;
        _errorMessage = null;
      });
    } catch (error, stack) {
      debugPrint('Dashboard load failed: $error\n$stack');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load dashboard.\n${error.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _openRegister() async {
    if (widget.onOpenRegister!= null) {
      widget.onOpenRegister!();
      return;
    }

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterSiteScreen()),
    );
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('d MMM yyyy').format(DateTime.now());
    final totalTypeCount = _stats.countsByType.values.fold<int>(0, (a, b) => a + b);
    final totalVillageCount = _stats.countsByVillage.values.fold<int>(0, (a, b) => a + b);
    final maxVillageCount = _stats.countsByVillage.values.isEmpty
       ? 1
        : _stats.countsByVillage.values.reduce((a, b) => a > b? a : b);
    final screenWidth = MediaQuery.of(context).size.width;

    final quickActionColumns = screenWidth >= 900
       ? 4
        : screenWidth >= 700
           ? 4
            : screenWidth >= 500
               ? 3
                : 2;

    final siteTypeColumns = screenWidth >= 900
       ? 6
        : screenWidth >= 700
           ? 4
            : screenWidth >= 500
               ? 4
                : 2;

    return Scaffold(
      body: _loading
         ? const Center(child: CircularProgressIndicator())
          : _errorMessage!= null
             ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                        const SizedBox(height: 20),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _bootstrap,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text('Good morning, Enumerator 👋',
                          style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Dashboard Overview',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 14),
                                const SizedBox(width: 6),
                                Text(today, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- Hero summary card ---
                      TotalSitesCard(
                        total: _stats.totalSites,
                        deltaToday: _stats.registeredToday,
                        today: _stats.registeredToday,
                        thisWeek: _stats.registeredThisWeek,
                        villages: _stats.villageCount,
                      ),
                      const SizedBox(height: 24),

                      // --- Quick actions ---
                      SectionHeader(
                          title: 'Quick Actions',
                          actionLabel: 'Customise',
                          actionIcon: Icons.settings_outlined,
                          onAction: () {}),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: quickActionColumns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.95,
                        children: [
                          QuickActionButton(
                              icon: Icons.add,
                              title: 'Register',
                              subtitle: 'New Site',
                              highlighted: true,
                              onTap: _openRegister),
                          QuickActionButton(
                              icon: Icons.search,
                              title: 'Search',
                              subtitle: 'Find Sites',
                              onTap: () => widget.onNavigate?.call(1)),
                          QuickActionButton(
                              icon: Icons.map_outlined,
                              title: 'Map View',
                              subtitle: 'View on Map',
                              onTap: () => widget.onNavigate?.call(3)),
                          QuickActionButton(
                              icon: Icons.bar_chart,
                              title: 'Reports',
                              subtitle: 'Analytics',
                              onTap: () => widget.onNavigate?.call(4)),
                          QuickActionButton(
                              icon: Icons.person_outline,
                              title: 'Profile',
                              subtitle: 'Enumerator',
                              onTap: () => widget.onNavigate?.call(5)),
                          QuickActionButton(
                              icon: Icons.cloud_upload_outlined,
                              title: 'Local Save',
                              subtitle: 'Offline Ready',
                              onTap: _openRegister),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- By site type ---
                      SectionHeader(title: 'By Site Type', actionLabel: 'View Details', onAction: () {}),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: SiteType.values.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: siteTypeColumns,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 165,
                        ),
                        itemBuilder: (context, index) {
                          final type = SiteType.values[index];
                          final count = _stats.countsByType[type]?? 0;
                          final pct = totalTypeCount == 0? 0.0 : (count / totalTypeCount) * 100;

                          return SiteTypeCard(
                            type: type,
                            count: count,
                            percentage: pct,
                          );
                        },
                      ),
                      const SizedBox(height: 40),

                      // --- Recent registrations ---
                      SectionHeader(title: 'Recent Registrations', actionLabel: 'View All', onAction: () {}),
                      const SizedBox(height: 4),
                      if (_recent.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('No sites registered yet.',
                              style: TextStyle(color: AppColors.textSecondary)),
                        )
                      else
                       ..._recent.map((s) => RecentRegistrationTile(site: s)),
                      const SizedBox(height: 24),

                      // --- Top villages ---
                      if (_stats.countsByVillage.isNotEmpty)...[
                        SectionHeader(title: 'Top Villages', actionLabel: 'View All', onAction: () {}),
                        const SizedBox(height: 4),
                       ..._stats.countsByVillage.entries.take(5).map((e) {
                          final pct = totalVillageCount == 0? 0.0 : (e.value / totalVillageCount) * 100;
                          return VillageProgressRow(
                            village: e.key,
                            count: e.value,
                            percentage: pct,
                            fraction: e.value / maxVillageCount,
                          );
                        }),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
    );
  }
}