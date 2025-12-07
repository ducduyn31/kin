import 'package:flutter/material.dart';

enum AvailabilityStatus { available, busy, away, offline }

extension AvailabilityStatusX on AvailabilityStatus {
  Color get color {
    switch (this) {
      case AvailabilityStatus.available:
        return Colors.green;
      case AvailabilityStatus.busy:
        return Colors.red;
      case AvailabilityStatus.away:
        return Colors.orange;
      case AvailabilityStatus.offline:
        return Colors.grey;
    }
  }

  String get label {
    switch (this) {
      case AvailabilityStatus.available:
        return 'Available';
      case AvailabilityStatus.busy:
        return 'Busy';
      case AvailabilityStatus.away:
        return 'Away';
      case AvailabilityStatus.offline:
        return 'Offline';
    }
  }
}

class Contact {
  final String id;
  final String name;
  final String avatarUrl;
  final AvailabilityStatus status;
  final String? statusMessage;

  const Contact({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.status,
    this.statusMessage,
  });

  bool get isOnline => status != AvailabilityStatus.offline;
}
