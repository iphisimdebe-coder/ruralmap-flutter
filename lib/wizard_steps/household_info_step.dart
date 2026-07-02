import 'package:flutter/material.dart';

/// Step 5 — collects household head, size, and contact details.
class HouseholdInfoStep extends StatelessWidget {
  final TextEditingController householdHeadController;
  final TextEditingController householdSizeController;
  final TextEditingController phoneController;

  const HouseholdInfoStep({
    super.key,
    required this.householdHeadController,
    required this.householdSizeController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text('Household Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Capture the household head, size, and contact information.'),
        const SizedBox(height: 16),
        TextFormField(
          controller: householdHeadController,
          decoration: const InputDecoration(labelText: 'Household Head', border: OutlineInputBorder()),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: householdSizeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Household Size', border: OutlineInputBorder()),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
        ),
      ],
    );
  }
}