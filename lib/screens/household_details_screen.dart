import 'package:flutter/material.dart';

import '../models/site.dart';

class HouseholdDetailsScreen extends StatelessWidget {
  final Site site;

  const HouseholdDetailsScreen({super.key, required this.site});

  Widget _detailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Household Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(site.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      '${site.type.label} • ${site.village}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Registered ${site.registeredAt.day}/${site.registeredAt.month}/${site.registeredAt.year}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Household details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _detailTile('Household head', site.householdHead ?? ''),
            _detailTile('Household size', site.householdSize?.toString() ?? ''),
            _detailTile('Contact phone', site.phoneNumber ?? ''),
            const SizedBox(height: 20),
            const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _detailTile('Site code', site.siteCode),
            _detailTile('Province', site.province),
            _detailTile('District', site.district),
            _detailTile('Municipality', site.municipality),
            _detailTile('Ward', site.ward),
            _detailTile('Traditional authority', site.traditionalAuthority),
            _detailTile('Section', site.section),
            _detailTile('Village', site.village),
            _detailTile('Address', site.address ?? ''),
            _detailTile('Landmark', site.landmark ?? ''),
            _detailTile('Directions', site.directions),
            _detailTile('Distance from landmark', site.distanceFromLandmark != null ? '${site.distanceFromLandmark} m' : ''),
            const SizedBox(height: 20),
            const Text('Additional notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(site.notes ?? 'No notes provided'),
            const SizedBox(height: 24),
            const Text('GPS coordinates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _detailTile('Latitude', site.latitude?.toStringAsFixed(6) ?? ''),
            _detailTile('Longitude', site.longitude?.toStringAsFixed(6) ?? ''),
          ],
        ),
      ),
    );
  }
}
