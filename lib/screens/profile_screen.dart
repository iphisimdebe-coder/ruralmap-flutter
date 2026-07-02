import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String version = "";

  @override
  void initState() {
    super.initState();
    loadVersion();
  }

  Future<void> loadVersion() async {
    final info = await PackageInfo.fromPlatform();

    if (!mounted) return;
    setState(() {
      version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {

    return ListView(

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
                  child: Icon(Icons.person,size:40),
                ),

                const SizedBox(height:12),

                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    final user = auth.user;
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
                      ],
                    );
                  },
                ),

                const SizedBox(height:16),

                FilledButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final updated = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                    );
                    if (mounted && updated == true) {
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

        const SizedBox(height:20),

        _sectionTitle("Field Statistics"),

        Card(
          child: Column(

            children: const [

              ListTile(
                leading: Icon(Icons.home_work),
                title: Text("Sites Registered"),
                trailing: Text("1,244"),
              ),

              Divider(),

              ListTile(
                leading: Icon(Icons.location_on),
                title: Text("GPS Captured"),
                trailing: Text("1,236"),
              ),

              Divider(),

              ListTile(
                leading: Icon(Icons.cloud_upload),
                title: Text("Pending Sync"),
                trailing: Text("23"),
              ),

            ],
          ),
        ),

        const SizedBox(height:20),

        _sectionTitle("Data Management"),

        Card(

          child: Column(

            children: [

              ListTile(

                leading: const Icon(Icons.sync),

                title: const Text("Sync Data"),

                subtitle: const Text("Upload unsynced records"),

                trailing: const Icon(Icons.chevron_right),

                onTap: () {},

              ),

              const Divider(),

              ListTile(

                leading: const Icon(Icons.download),

                title: const Text("Export Database"),

                trailing: const Icon(Icons.chevron_right),

                onTap: () {},

              ),

              const Divider(),

              ListTile(

                leading: const Icon(Icons.upload),

                title: const Text("Import Database"),

                trailing: const Icon(Icons.chevron_right),

                onTap: () {},

              ),

              const Divider(),

              ListTile(

                leading: const Icon(Icons.backup),

                title: const Text("Backup Database"),

                trailing: const Icon(Icons.chevron_right),

                onTap: () {},

              ),

            ],
          ),
        ),

        const SizedBox(height:20),

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

                subtitle: const Text("23 MB"),

              ),

            ],
          ),
        ),

        const SizedBox(height:20),

        _sectionTitle("Application"),

        Card(

          child: Column(

            children: [

              SwitchListTile(

                value: false,

                onChanged: (v){},

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

        const SizedBox(height:20),

        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () async {
            await context.read<AuthProvider>().logout();
          },
          icon: const Icon(Icons.logout),
          label: const Text("Logout"),
        ),

        const SizedBox(height:40),

      ],
    );
  }

  Widget _sectionTitle(String title){

    return Padding(

      padding: const EdgeInsets.only(bottom:10),

      child: Text(

        title,

        style: const TextStyle(

          fontWeight: FontWeight.bold,

          fontSize:18,

        ),

      ),

    );

  }

}