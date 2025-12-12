/// Privacy level for sharing with a circle
enum PrivacyLevel {
  basic, // Minimal info
  medium, // Standard info
  full, // All info
}

extension PrivacyLevelX on PrivacyLevel {
  String get label {
    switch (this) {
      case PrivacyLevel.basic:
        return 'Limited';
      case PrivacyLevel.medium:
        return 'Standard';
      case PrivacyLevel.full:
        return 'Full Access';
    }
  }

  String get description {
    switch (this) {
      case PrivacyLevel.basic:
        return 'Only basic status (online/offline)';
      case PrivacyLevel.medium:
        return 'Status with availability message';
      case PrivacyLevel.full:
        return 'Full status, location, and activity';
    }
  }

  String toApiValue() => name;

  static PrivacyLevel fromApiValue(String value) {
    switch (value) {
      case 'basic':
        return PrivacyLevel.basic;
      case 'medium':
        return PrivacyLevel.medium;
      case 'full':
        return PrivacyLevel.full;
      default:
        return PrivacyLevel.medium;
    }
  }
}

/// Location precision for sharing
enum LocationPrecision { city, region, exact }

extension LocationPrecisionX on LocationPrecision {
  String get label {
    switch (this) {
      case LocationPrecision.city:
        return 'City';
      case LocationPrecision.region:
        return 'Region';
      case LocationPrecision.exact:
        return 'Exact';
    }
  }

  String toApiValue() => name;

  static LocationPrecision fromApiValue(String value) {
    switch (value) {
      case 'city':
        return LocationPrecision.city;
      case 'region':
        return LocationPrecision.region;
      case 'exact':
        return LocationPrecision.exact;
      default:
        return LocationPrecision.city;
    }
  }
}

/// User's sharing preferences for a specific circle
class SharingPreference {
  final String id;
  final String circleId;
  final String userId;
  final PrivacyLevel privacyLevel;
  final bool shareTimezone;
  final bool shareAvailability;
  final bool shareLocation;
  final LocationPrecision locationPrecision;
  final bool shareActivity;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SharingPreference({
    required this.id,
    required this.circleId,
    required this.userId,
    this.privacyLevel = PrivacyLevel.medium,
    this.shareTimezone = true,
    this.shareAvailability = true,
    this.shareLocation = false,
    this.locationPrecision = LocationPrecision.city,
    this.shareActivity = false,
    required this.createdAt,
    required this.updatedAt,
  });

  SharingPreference copyWith({
    String? id,
    String? circleId,
    String? userId,
    PrivacyLevel? privacyLevel,
    bool? shareTimezone,
    bool? shareAvailability,
    bool? shareLocation,
    LocationPrecision? locationPrecision,
    bool? shareActivity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SharingPreference(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      userId: userId ?? this.userId,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      shareTimezone: shareTimezone ?? this.shareTimezone,
      shareAvailability: shareAvailability ?? this.shareAvailability,
      shareLocation: shareLocation ?? this.shareLocation,
      locationPrecision: locationPrecision ?? this.locationPrecision,
      shareActivity: shareActivity ?? this.shareActivity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
