/// The category of a registered site. Mirrors the "By Site Type" section
/// of the dashboard (House / Business / Church / School).
enum SiteType { house, business, church, school }

extension SiteTypeX on SiteType {
  String get label {
    switch (this) {
      case SiteType.house:
        return 'House';
      case SiteType.business:
        return 'Business';
      case SiteType.church:
        return 'Church';
      case SiteType.school:
        return 'School';
    }
  }

  static SiteType fromString(String value) {
    return SiteType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SiteType.house,
    );
  }
}

/// A single registered census record. This is the row shape stored in
/// the local SQLite `sites` table.
class Site {
  final int? id;
  final String name;
  final String village;
  final SiteType type;
  final DateTime registeredAt;
  final String? imagePath;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? landmark;
  final String? description;
  final String? householdHead;
  final int? householdSize;
  final String? phoneNumber;
  final String? services;
  final String? notes;
  final String siteCode;
final String province;
final String district;
final String municipality;
final String ward;
final String traditionalAuthority;
final String section;
final String directions;
final double? distanceFromLandmark;

const Site({
  this.id,

  required this.siteCode,
  required this.name,
  required this.province,
  required this.district,
  required this.municipality,
  required this.ward,
  required this.traditionalAuthority,
  required this.village,
  required this.section,

  required this.type,
  required this.registeredAt,

  this.imagePath,
  this.latitude,
  this.longitude,

  this.address,
  this.landmark,
  this.distanceFromLandmark,
  required this.directions,

  this.description,
  this.householdHead,
  this.householdSize,
  this.phoneNumber,
  this.services,
  this.notes,
});

  Site copyWith({
    int? id,
    String? name,
    String? village,
    SiteType? type,
    DateTime? registeredAt,
    String? imagePath,
    double? latitude,
    double? longitude,
    String? address,
    String? landmark,
    String? description,
    String? householdHead,
    int? householdSize,
    String? phoneNumber,
    String? services,
    String? notes,
  }) {
    return Site(
      id: id ?? this.id,
      name: name ?? this.name,
      village: village ?? this.village,
      type: type ?? this.type,
      registeredAt: registeredAt ?? this.registeredAt,
      imagePath: imagePath ?? this.imagePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      description: description ?? this.description,
      householdHead: householdHead ?? this.householdHead,
      householdSize: householdSize ?? this.householdSize,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      services: services ?? this.services,
      notes: notes ?? this.notes, siteCode: '', province: '', district: '', municipality: '', ward: '', traditionalAuthority: '', section: '', directions: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'village': village,
      'type': type.name,
      'registered_at': registeredAt.toIso8601String(),
      'image_path': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'landmark': landmark,
      'description': description,
      'household_head': householdHead,
      'household_size': householdSize,
      'phone_number': phoneNumber,
      'services': services,
      'notes': notes,
    };
  }

  factory Site.fromMap(Map<String, dynamic> map) {
    return Site(
      id: map['id'] as int?,
      name: map['name'] as String,
      village: map['village'] as String,
      type: SiteTypeX.fromString(map['type'] as String),
      registeredAt: DateTime.parse(map['registered_at'] as String),
      imagePath: map['image_path'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      address: map['address'] as String?,
      landmark: map['landmark'] as String?,
      description: map['description'] as String?,
      householdHead: map['household_head'] as String?,
      householdSize: map['household_size'] as int?,
      phoneNumber: map['phone_number'] as String?,
      services: map['services'] as String?,
      notes: map['notes'] as String?, siteCode: '', province: '', district: '', municipality: '', ward: '', traditionalAuthority: '', section: '', directions: '',
    );
  }
}

/// Aggregate counts used to populate the dashboard summary card.
class DashboardStats {
  final int totalSites;
  final int registeredToday;
  final int registeredThisWeek;
  final int villageCount;
  final Map<SiteType, int> countsByType;
  final Map<String, int> countsByVillage;

  const DashboardStats({
    required this.totalSites,
    required this.registeredToday,
    required this.registeredThisWeek,
    required this.villageCount,
    required this.countsByType,
    required this.countsByVillage,
  });

  factory DashboardStats.empty() => const DashboardStats(
        totalSites: 0,
        registeredToday: 0,
        registeredThisWeek: 0,
        villageCount: 0,
        countsByType: {},
        countsByVillage: {},
      );
}
