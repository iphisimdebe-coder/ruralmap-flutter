import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/site.dart';

class HouseholdDetailsScreen extends StatelessWidget {
  final Site site;
  final VoidCallback? onEdit; // callback to handle edit

  const HouseholdDetailsScreen({
    super.key,
    required this.site,
    this.onEdit,
  });

  Widget _detailTile(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.green.shade700,
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                value.isEmpty ? "Not provided" : value,
                style: TextStyle(
                  fontSize: 15,
                  color: onTap != null ? Colors.blue : null,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
            ?trailing, // Fixed: Dart 3.6 syntax
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ?trailing, // Fixed: Dart 3.6 syntax
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (site.imagePath == null || site.imagePath!.isEmpty) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            Icons.home,
            size: 90,
            color: Colors.grey,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _FullImageScreen(
              imagePath: site.imagePath!,
            ),
          ),
        );
      },
      child: Hero(
        tag: site.imagePath!,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(site.imagePath!),
            height: 240,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: child,
      ),
    );
  }

  Future<void> _launchGoogleMaps() async {
    if (site.latitude == null || site.longitude == null) return;
    final lat = site.latitude!;
    final lng = site.longitude!;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchOSM() async {
    if (site.latitude == null || site.longitude == null) return;
    final lat = site.latitude!;
    final lng = site.longitude!;
    final uri = Uri.parse(
      'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=18/$lat/$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showNavigationOptions(BuildContext context) async {
    if (site.latitude == null || site.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS coordinates not available')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Google Maps'),
              onTap: () {
                Navigator.pop(context);
                _launchGoogleMaps();
              },
            ),
            ListTile(
              leading: const Icon(Icons.explore),
              title: const Text('OpenStreetMap'),
              onTap: () {
                Navigator.pop(context);
                _launchOSM();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Site Code: ${site.siteCode}'),
        content: SizedBox(
          width: 250,
          height: 250,
          child: Center(
            child: QrImageView(
              data: site.siteCode,
              version: QrVersions.auto,
              size: 220,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasGPS = site.latitude != null && site.longitude != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Household Details"),
        actions: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Household',
              onPressed: onEdit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildImage(context),
            const SizedBox(height: 18),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    site.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.location_city, size: 18),
                        label: Text(site.type.label),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.qr_code, size: 18),
                        label: const Text('Show QR'),
                        onPressed: () => _showQRCode(context),
                      ),
                      if (hasGPS)
                        ActionChip(
                          avatar: const Icon(Icons.directions, size: 18),
                          label: const Text('Navigate'),
                          onPressed: () => _showNavigationOptions(context),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    site.village,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Registered on ${site.registeredAt.day}/${site.registeredAt.month}/${site.registeredAt.year}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Household Information", Icons.family_restroom),
                  _detailTile(Icons.person, "Household Head", site.householdHead ?? ""),
                  _detailTile(Icons.groups, "Household Size", site.householdSize?.toString() ?? ""),
                  _detailTile(
                    Icons.phone,
                    "Phone",
                    site.phoneNumber ?? "",
                    onTap: site.phoneNumber?.isNotEmpty == true
                        ? () => launchUrl(Uri.parse('tel:${site.phoneNumber}'))
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Location", Icons.location_on),
                  _detailTile(
                    Icons.qr_code,
                    "Site Code",
                    site.siteCode,
                    trailing: IconButton(
                      icon: const Icon(Icons.qr_code_2, size: 20),
                      onPressed: () => _showQRCode(context),
                    ),
                  ),
                  _detailTile(Icons.map, "Province", site.province),
                  _detailTile(Icons.map, "District", site.district),
                  _detailTile(Icons.location_city, "Municipality", site.municipality),
                  _detailTile(Icons.flag, "Ward", site.ward),
                  _detailTile(Icons.groups, "Traditional Authority", site.traditionalAuthority),
                  _detailTile(Icons.home_work, "Section", site.section),
                  _detailTile(Icons.location_city, "Village", site.village),
                  _detailTile(Icons.location_pin, "Address", site.address ?? ""),
                  _detailTile(Icons.place, "Landmark", site.landmark ?? ""),
                 
                ],
              ),
            ),

            const SizedBox(height: 18),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(
                    "GPS Coordinates",
                    Icons.gps_fixed,
                  ),
                  _detailTile(
                    Icons.my_location,
                    "Latitude",
                    site.latitude?.toStringAsFixed(6) ?? "",
                    onTap: hasGPS ? () => _showNavigationOptions(context) : null,
                  ),
                  _detailTile(
                    Icons.my_location,
                    "Longitude",
                    site.longitude?.toStringAsFixed(6) ?? "",
                    onTap: hasGPS ? () => _showNavigationOptions(context) : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Notes", Icons.description),
                  Text(
                    site.notes?.isEmpty ?? true ? "No notes provided" : site.notes!,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _FullImageScreen extends StatelessWidget {
  final String imagePath;

  const _FullImageScreen({
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Hero(
          tag: imagePath,
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Image.file(
              File(imagePath),
            ),
          ),
        ),
      ),
    );
  }
}