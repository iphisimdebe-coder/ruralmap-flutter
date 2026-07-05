import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/db_helper.dart';
import '../providers/auth_provider.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String version = "";
  Map<String, int> _stats = {'totalSites': 0, 'gpsCaptured': 0, 'pendingSync': 0};
  String _dbSize = "Loading...";
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadVersion(),
      _loadStats(),
      _loadDbSize(),
    ]);
    if (mounted) setState(() => _loadingStats = false);
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => version = info.version);
  }

  Future<void> _loadStats() async {
    final stats = await DBHelper.instance.getFieldStats();
    if (!mounted) return;
    setState(() => _stats = stats);
  }

  Future<void> _loadDbSize() async {
    final size = await DBHelper.instance.getDatabaseSize();
    if (!mounted) return;
    setState(() => _dbSize = size);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _exportToExcel() async {
    try {
      _showMessage('Generating Excel file...');
      final path = await DBHelper.instance.exportSitesToExcel();
      if (!mounted) return;
      _showMessage('Excel exported to: $path');
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(path)], text: 'GeoRura Sites Export');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Excel export failed: ${error.toString()}');
    }
  }

  Future<void> _exportToCsv() async {
    try {
      _showMessage('Generating CSV file...');
      final path = await DBHelper.instance.exportSitesToCsv();
      if (!mounted) return;
      _showMessage('CSV exported to: $path');
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(path)], text: 'GeoRura Sites Export');
    } catch (error) {
      if (!mounted) return;
      _showMessage('CSV export failed: ${error.toString()}');
    }
  }

  Future<void> _exportDatabase() async {
    try {
      final path = await DBHelper.instance.exportDatabase();
      if (!mounted) return;
      _showMessage('Exported database to: $path');
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(path)], text: 'Database backup');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Export failed: ${error.toString()}');
    }
  }

  Future<void> _backupDatabase() async {
    try {
      final path = await DBHelper.instance.backupDatabase();
      if (!mounted) return;
      _showMessage('Backup saved to: $path');
      _loadDbSize(); // Refresh size
    } catch (error) {
      if (!mounted) return;
      _showMessage('Backup failed: ${error.toString()}');
    }
  }

  Future<void> _importDatabase() async {
    try {
      final restoredPath = await DBHelper.instance.restoreLatestBackup();
      if (restoredPath == null) {
        if (!mounted) return;
        _showMessage('No backup file found to import.');
        return;
      }
      if (!mounted) return;
      _showMessage('Database restored from backup: $restoredPath');
      _loadAllData(); // Refresh all stats
    } catch (error) {
      if (!mounted) return;
      _showMessage('Import failed: ${error.toString()}');
    }
  }

  Future<void> _showExportOptions() async {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Export to Excel (.xlsx)'),
                subtitle: const Text('Best for opening in Excel/Google Sheets'),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportToExcel();
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_snippet),
                title: const Text('Export to CSV (.csv)'),
                subtitle: const Text('Universal format, smaller file'),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportToCsv();
                },
              ),
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Export Raw Database (.db)'),
                subtitle: const Text('Full SQLite file for backup'),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportDatabase();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      final user = auth.currentUser;
                      return Column(
                        children: [
                          Text(
                            user?.name ?? 'Enumerator',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user == null
                                ? 'No account details available'
                                : '${user.role} • ${user.phone}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (user?.email != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              user!.email,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final updated = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                      );
                      if (!mounted) return;
                      if (updated == true) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Profile updated successfully.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle("Field Statistics"),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.home_work),
                  title: const Text("Sites Registered"),
                  trailing: _loadingStats 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text("${_stats['totalSites']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text("GPS Captured"),
                  trailing: _loadingStats 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text("${_stats['gpsCaptured']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.cloud_upload, color: (_stats['pendingSync'] ?? 0) > 0 ? Colors.orange : null),
                  title: const Text("Pending Sync"),
                  trailing: _loadingStats 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          "${_stats['pendingSync']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (_stats['pendingSync'] ?? 0) > 0 ? Colors.orange : null,
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle("Data Management"),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: const Text("Sync Data"),
                  subtitle: const Text("Upload unsynced records"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showMessage('Sync not implemented yet'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text("Export Sites"),
                  subtitle: const Text("Excel, CSV, or Database"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showExportOptions,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: const Text("Import Database"),
                  subtitle: const Text("Restore from latest backup"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _importDatabase,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text("Backup Database"),
                  subtitle: const Text("Create local backup copy"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _backupDatabase,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle("Device"),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.gps_fixed),
                  title: const Text("GPS Status"),
                  subtitle: const Text("Ready"),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text("Database"),
                  subtitle: const Text("SQLite Local Storage"),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.memory),
                  title: const Text("Storage Used"),
                  subtitle: Text(_dbSize),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadDbSize,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle("Application"),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: false,
                  onChanged: (v) {},
                  title: const Text("Dark Mode"),
                  secondary: const Icon(Icons.dark_mode),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text("Help"),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text("Privacy Policy"),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("Version"),
                  subtitle: Text(version),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              if (!mounted) return;
              await context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}