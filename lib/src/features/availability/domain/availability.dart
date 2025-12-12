import 'availability_status.dart';

class _Undefined {
  const _Undefined();
}

const _undefined = _Undefined();

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
    Object? statusMessage = _undefined,
    Object? manualUntil = _undefined,
    bool? autoStatus,
    DateTime? updatedAt,
  }) {
    return Availability(
      userId: userId ?? this.userId,
      status: status ?? this.status,
      statusMessage: statusMessage == _undefined
          ? this.statusMessage
          : statusMessage as String?,
      manualUntil: manualUntil == _undefined
          ? this.manualUntil
          : manualUntil as DateTime?,
      autoStatus: autoStatus ?? this.autoStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isManualStatusExpired {
    if (manualUntil == null) return false;
    return !DateTime.now().isBefore(manualUntil!);
  }
}

enum AvailabilityDuration {
  indefinite,
  thirtyMinutes,
  oneHour,
  fourHours,
  untilTomorrow,
}

extension AvailabilityDurationX on AvailabilityDuration {
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
        final todayAt9 = DateTime(now.year, now.month, now.day, 9);
        return now.isBefore(todayAt9)
            ? todayAt9
            : todayAt9.add(const Duration(days: 1));
    }
  }
}
