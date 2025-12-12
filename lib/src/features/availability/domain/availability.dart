import 'availability_status.dart';

/// User's current availability state
class Availability {
  final String userId;
  final AvailabilityStatus status;
  final String? statusMessage;
  final DateTime? manualUntil;
  final bool autoStatus;
  final DateTime updatedAt;

  const Availability({
    required this.userId,
    required this.status,
    this.statusMessage,
    this.manualUntil,
    this.autoStatus = false,
    required this.updatedAt,
  });

  Availability copyWith({
    String? userId,
    AvailabilityStatus? status,
    String? statusMessage,
    DateTime? manualUntil,
    bool? autoStatus,
    DateTime? updatedAt,
  }) {
    return Availability(
      userId: userId ?? this.userId,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      manualUntil: manualUntil ?? this.manualUntil,
      autoStatus: autoStatus ?? this.autoStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if manual status has expired
  bool get isManualStatusExpired {
    if (manualUntil == null) return false;
    return DateTime.now().isAfter(manualUntil!);
  }
}

/// Duration options for setting availability
enum AvailabilityDuration {
  indefinite,
  thirtyMinutes,
  oneHour,
  fourHours,
  untilTomorrow,
}

extension AvailabilityDurationX on AvailabilityDuration {
  String get label {
    switch (this) {
      case AvailabilityDuration.indefinite:
        return 'Until I change it';
      case AvailabilityDuration.thirtyMinutes:
        return 'For 30 minutes';
      case AvailabilityDuration.oneHour:
        return 'For 1 hour';
      case AvailabilityDuration.fourHours:
        return 'For 4 hours';
      case AvailabilityDuration.untilTomorrow:
        return 'Until tomorrow';
    }
  }

  DateTime? get expiresAt {
    final now = DateTime.now();
    switch (this) {
      case AvailabilityDuration.indefinite:
        return null;
      case AvailabilityDuration.thirtyMinutes:
        return now.add(const Duration(minutes: 30));
      case AvailabilityDuration.oneHour:
        return now.add(const Duration(hours: 1));
      case AvailabilityDuration.fourHours:
        return now.add(const Duration(hours: 4));
      case AvailabilityDuration.untilTomorrow:
        // Next day at 9 AM
        final tomorrow = DateTime(now.year, now.month, now.day + 1, 9);
        return tomorrow;
    }
  }
}
