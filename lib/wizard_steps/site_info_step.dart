import 'package:flutter/material.dart';

/// Step 4 — Collects basic site identity and administrative location.
class SiteInfoStep extends StatelessWidget {
  final TextEditingController siteNameController;
  final TextEditingController siteCodeController;

  final TextEditingController provinceController;
  final TextEditingController districtController;
  final TextEditingController municipalityController;
  final TextEditingController wardController;
  final TextEditingController traditionalAuthorityController;
  final TextEditingController villageController;
  final TextEditingController sectionController;

  final TextEditingController landmarkController;
  final TextEditingController distanceController;
  final TextEditingController addressController;
  final TextEditingController directionsController;

  const SiteInfoStep({
    super.key,
    required this.siteNameController,
    required this.siteCodeController,
    required this.provinceController,
    required this.districtController,
    required this.municipalityController,
    required this.wardController,
    required this.traditionalAuthorityController,
    required this.villageController,
    required this.sectionController,
    required this.landmarkController,
    required this.distanceController,
    required this.addressController,
    required this.directionsController,
  });

  @override
  Widget build(BuildContext context) {
    InputDecoration decoration(String label, {IconData? icon}) {
      return InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Site Information',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Record the site identity and administrative location.',
        ),

        const SizedBox(height: 24),

        TextFormField(
          controller: siteNameController,
          decoration: decoration(
            'Site / Household Name',
            icon: Icons.home_work_outlined,
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Required' : null,
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: siteCodeController,
          readOnly: true,
          decoration: decoration(
            'Site Code',
            icon: Icons.qr_code,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Administrative Area',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: provinceController,
          decoration: decoration(
            'Province',
            icon: Icons.map_outlined,
          ),
        ),

        const SizedBox(height: 12),

        TextFormField(
          controller: districtController,
          decoration: decoration(
            'District',
            icon: Icons.location_city_outlined,
          ),
        ),

        const SizedBox(height: 12),

        TextFormField(
          controller: municipalityController,
          decoration: decoration(
            'Municipality',
            icon: Icons.account_balance_outlined,
          ),
        ),

        const SizedBox(height: 12),

        TextFormField(
          controller: wardController,
          decoration: decoration(
            'Ward',
            icon: Icons.pin_drop_outlined,
          ),
        ),

        const SizedBox(height: 12),

        TextFormField(
          controller: traditionalAuthorityController,
          decoration: decoration(
            'Traditional Authority',
            icon: Icons.groups_outlined,
          ),
        ),

        const SizedBox(height: 12),

        TextFormField(
          controller: villageController,
          decoration: decoration(
            'Village',
            icon: Icons.location_on_outlined,
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Required' : null,
        ),

        const SizedBox(height: 12),

        TextFormField(
          controller: sectionController,
          decoration: decoration(
            'Section / Area',
            icon: Icons.grid_view_outlined,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Location Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: landmarkController,
          decoration: decoration(
            'Nearest Landmark',
            icon: Icons.place_outlined,
          ),
        ),

        const SizedBox(height: 12),

        TextFormField(
          controller: distanceController,
          keyboardType: TextInputType.number,
          decoration: decoration(
            'Distance from Landmark (m)',
            icon: Icons.straighten,
          ),
        ),

        const SizedBox(height: 12),

        TextFormField(
          controller: addressController,
          maxLines: 2,
          decoration: decoration(
            'Physical Address',
            icon: Icons.home_outlined,
          ),
        ),

        const SizedBox(height: 12),

        TextFormField(
          controller: directionsController,
          maxLines: 3,
          decoration: decoration(
            'Directions to the Site',
            icon: Icons.alt_route,
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}