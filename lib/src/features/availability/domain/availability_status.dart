import 'package:flutter/material.dart';

/// Availability status matching backend API
/// Backend values: free, busy, do_not_disturb, sleeping, away
enum AvailabilityStatus {
  free,
  busy,
  doNotDisturb,
  sleeping,
  away,
  offline, // Client-side only for presence
}

extension AvailabilityStatusX on AvailabilityStatus {
  Color get color {
    switch (this) {
      case AvailabilityStatus.free:
        return const Color(0xFF4CAF50); // Green
      case AvailabilityStatus.busy:
        return const Color(0xFFF44336); // Red
      case AvailabilityStatus.doNotDisturb:
        return const Color(0xFFB71C1C); // Dark Red
      case AvailabilityStatus.sleeping:
        return const Color(0xFF9C27B0); // Purple
      case AvailabilityStatus.away:
        return const Color(0xFFFF9800); // Orange
      case AvailabilityStatus.offline:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  IconData get icon {
    switch (this) {
      case AvailabilityStatus.free:
        return Icons.check_circle;
      case AvailabilityStatus.busy:
        return Icons.do_not_disturb;
      case AvailabilityStatus.doNotDisturb:
        return Icons.do_not_disturb_on;
      case AvailabilityStatus.sleeping:
        return Icons.bedtime;
      case AvailabilityStatus.away:
        return Icons.schedule;
      case AvailabilityStatus.offline:
        return Icons.circle_outlined;
    }
  }

  String get label {
    switch (this) {
      case AvailabilityStatus.free:
        return 'Free';
      case AvailabilityStatus.busy:
        return 'Busy';
      case AvailabilityStatus.doNotDisturb:
        return 'Do Not Disturb';
      case AvailabilityStatus.sleeping:
        return 'Sleeping';
      case AvailabilityStatus.away:
        return 'Away';
      case AvailabilityStatus.offline:
        return 'Offline';
    }
  }

  /// Convert to backend API value
  String toApiValue() {
    switch (this) {
      case AvailabilityStatus.free:
        return 'free';
      case AvailabilityStatus.busy:
        return 'busy';
      case AvailabilityStatus.doNotDisturb:
        return 'do_not_disturb';
      case AvailabilityStatus.sleeping:
        return 'sleeping';
      case AvailabilityStatus.away:
        return 'away';
      case AvailabilityStatus.offline:
        return 'offline';
    }
  }

  /// Parse from backend API value
  static AvailabilityStatus fromApiValue(String value) {
    switch (value) {
      case 'free':
        return AvailabilityStatus.free;
      case 'busy':
        return AvailabilityStatus.busy;
      case 'do_not_disturb':
        return AvailabilityStatus.doNotDisturb;
      case 'sleeping':
        return AvailabilityStatus.sleeping;
      case 'away':
        return AvailabilityStatus.away;
      case 'offline':
      default:
        return AvailabilityStatus.offline;
    }
  }

  bool get isAvailableToChat =>
      this == AvailabilityStatus.free || this == AvailabilityStatus.away;
}
