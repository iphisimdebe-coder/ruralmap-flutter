import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/db_helper.dart';
import '../models/site.dart';
import '../theme/app_theme.dart';

class RegisterSiteScreen extends StatefulWidget {
  const RegisterSiteScreen({super.key});

  @override
  State<RegisterSiteScreen> createState() => _RegisterSiteScreenState();
}

class _RegisterSiteScreenState extends State<RegisterSiteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _villageController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _householdHeadController = TextEditingController();
  final _householdSizeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();

  SiteType _selectedType = SiteType.house;
  int _currentStep = 0;
  bool _saving = false;
  bool _gpsLoading = false;
  bool _photoLoading = false;
  double? _latitude;
  double? _longitude;
  String? _photoPath;
  String _gpsStatus = 'Tap to capture your current location';
  final List<String> _services = [];

  @override
  void dispose() {
    _nameController.dispose();
    _villageController.dispose();
    _landmarkController.dispose();
    _descriptionController.dispose();
    _householdHeadController.dispose();
    _householdSizeController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() => _gpsLoading = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _gpsStatus = 'Location services are disabled.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        setState(() => _gpsStatus = 'Location permission was not granted.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      final place = placemarks.isNotEmpty ? placemarks.first : null;
      final addressParts = [
        place?.street,
        place?.subLocality,
        place?.locality,
        place?.administrativeArea,
        place?.country,
      ].whereType<String>().where((value) => value.trim().isNotEmpty);
      final resolvedAddress = addressParts.join(', ');

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _addressController.text = resolvedAddress;
        _gpsStatus = 'GPS captured successfully.';
        _gpsLoading = false;
      });
    } catch (_) {
      setState(() {
        _gpsLoading = false;
        _gpsStatus = 'Unable to capture location right now.';
      });
    }
  }

  Future<void> _capturePhoto() async {
    setState(() => _photoLoading = true);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (picked == null) {
        setState(() => _photoLoading = false);
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final targetPath = p.join(appDir.path, '${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}');
      final savedFile = await File(picked.path).copy(targetPath);

      setState(() {
        _photoPath = savedFile.path;
        _photoLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _photoLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo capture failed.')));
    }
  }

  Future<void> _openOsmMap() async {
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Capture GPS first.')));
      return;
    }

    final url = Uri.parse('https://www.openstreetmap.org/?mlat=$_latitude&mlon=$_longitude&zoom=16');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open OpenStreetMap.')));
    }
  }

  bool _validateStep() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        if (_latitude == null || _longitude == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GPS location is required.')));
          return false;
        }
        return true;
      case 2:
        if (_photoPath == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Capture at least one site photo.')));
          return false;
        }
        return true;
      case 3:
        if (_nameController.text.trim().isEmpty || _villageController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Site name and village are required.')));
          return false;
        }
        return true;
      case 4:
        if (_householdHeadController.text.trim().isEmpty || _householdSizeController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Household head and size are required.')));
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (!_validateStep()) return;
    setState(() => _currentStep = (_currentStep + 1).clamp(0, 6));
  }

  void _previousStep() {
    setState(() => _currentStep = (_currentStep - 1).clamp(0, 6));
  }

  Future<void> _saveSite() async {
    if (!_validateStep()) return;
    setState(() => _saving = true);

    final householdSize = int.tryParse(_householdSizeController.text.trim());
    final site = Site(
      name: _nameController.text.trim(),
      village: _villageController.text.trim(),
      type: _selectedType,
      registeredAt: DateTime.now(),
      imagePath: _photoPath,
      latitude: _latitude,
      longitude: _longitude,
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      landmark: _landmarkController.text.trim().isEmpty ? null : _landmarkController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      householdHead: _householdHeadController.text.trim().isEmpty ? null : _householdHeadController.text.trim(),
      householdSize: householdSize,
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      services: _services.isEmpty ? null : _services.join(', '),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    await DBHelper.instance.insertSite(site);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Site'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentStep + 1) / 7,
                  backgroundColor: AppColors.divider,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 10),
                Text('Step ${_currentStep + 1} of 7', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Expanded(child: _buildStep()),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          child: const Text('Back'),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentStep == 6 ? _saveSite : _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: _saving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(_currentStep == 6 ? 'Save Site' : 'Continue'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildStepOne();
      case 1:
        return _buildStepTwo();
      case 2:
        return _buildStepThree();
      case 3:
        return _buildStepFour();
      case 4:
        return _buildStepFive();
      case 5:
        return _buildStepSix();
      default:
        return _buildStepSeven();
    }
  }

  Widget _buildStepOne() {
    return ListView(
      children: [
        const Text('Choose Site Type', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Select the primary type of site you are registering.'),
        const SizedBox(height: 16),
        ...SiteType.values.map((type) {
          final selected = _selectedType == type;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
                  color: selected ? AppColors.houseBg : AppColors.surface,
                ),
                child: Row(
                  children: [
                    Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? AppColors.primary : AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(type.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStepTwo() {
    return ListView(
      children: [
        const Text('GPS Capture (OpenStreetMap)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Capture the site location automatically and reverse geocode the address.'),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _gpsLoading ? null : _captureLocation,
          icon: _gpsLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.gps_fixed),
          label: const Text('Use Current Location'),
        ),
        const SizedBox(height: 12),
        if (_latitude != null && _longitude != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Latitude: $_latitude'),
                  Text('Longitude: $_longitude'),
                  const SizedBox(height: 8),
                  Text(_addressController.text.isEmpty ? 'Address pending' : _addressController.text),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _openOsmMap,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Open in OpenStreetMap'),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(_gpsStatus, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildStepThree() {
    return ListView(
      children: [
        const Text('Capture Site Photos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Take a clear photo of the site for the offline record.'),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _photoLoading ? null : _capturePhoto,
          icon: _photoLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.camera_alt),
          label: const Text('Take Photo'),
        ),
        const SizedBox(height: 16),
        if (_photoPath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(File(_photoPath!), fit: BoxFit.cover, height: 220),
          ),
      ],
    );
  }

  Widget _buildStepFour() {
    return ListView(
      children: [
        const Text('Site Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Record the site identity and basic location details.'),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Site / Household Name', border: OutlineInputBorder()),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _villageController,
          decoration: const InputDecoration(labelText: 'Village', border: OutlineInputBorder()),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _landmarkController,
          decoration: const InputDecoration(labelText: 'Landmark', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildStepFive() {
    return ListView(
      children: [
        const Text('Household Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Capture the household head, size, and contact information.'),
        const SizedBox(height: 16),
        TextFormField(
          controller: _householdHeadController,
          decoration: const InputDecoration(labelText: 'Household Head', border: OutlineInputBorder()),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _householdSizeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Household Size', border: OutlineInputBorder()),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildStepSix() {
    return ListView(
      children: [
        const Text('Services & Infrastructure', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Select the services available at the site.'),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: _services.contains('Water'),
          title: const Text('Water Supply'),
          onChanged: (value) => setState(() {
            if (value == true) {
              _services.add('Water');
            } else {
              _services.remove('Water');
            }
          }),
        ),
        CheckboxListTile(
          value: _services.contains('Electricity'),
          title: const Text('Electricity'),
          onChanged: (value) => setState(() {
            if (value == true) {
              _services.add('Electricity');
            } else {
              _services.remove('Electricity');
            }
          }),
        ),
        CheckboxListTile(
          value: _services.contains('Sanitation'),
          title: const Text('Sanitation'),
          onChanged: (value) => setState(() {
            if (value == true) {
              _services.add('Sanitation');
            } else {
              _services.remove('Sanitation');
            }
          }),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildStepSeven() {
    return ListView(
      children: [
        const Text('Review', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Everything looks ready to save locally.'),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Site Type: ${_selectedType.label}'),
                Text('Site Name: ${_nameController.text.trim()}'),
                Text('Village: ${_villageController.text.trim()}'),
                Text('Address: ${_addressController.text.trim().isEmpty ? "Not captured" : _addressController.text.trim()}'),
                Text('Household Head: ${_householdHeadController.text.trim().isEmpty ? "Not captured" : _householdHeadController.text.trim()}'),
                Text('Services: ${_services.isEmpty ? "None" : _services.join(", ")}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_photoPath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(File(_photoPath!), fit: BoxFit.cover, height: 220),
          ),
      ],
    );
  }
}
