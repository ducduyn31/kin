import 'availability_status.dart';

/// Weekday enum for availability windows
enum Weekday { sunday, monday, tuesday, wednesday, thursday, friday, saturday }

extension WeekdayX on Weekday {
  String get shortLabel {
    switch (this) {
      case Weekday.sunday:
        return 'Sun';
      case Weekday.monday:
        return 'Mon';
      case Weekday.tuesday:
        return 'Tue';
      case Weekday.wednesday:
        return 'Wed';
      case Weekday.thursday:
        return 'Thu';
      case Weekday.friday:
        return 'Fri';
      case Weekday.saturday:
        return 'Sat';
    }
  }

  String get label {
    switch (this) {
      case Weekday.sunday:
        return 'Sunday';
      case Weekday.monday:
        return 'Monday';
      case Weekday.tuesday:
        return 'Tuesday';
      case Weekday.wednesday:
        return 'Wednesday';
      case Weekday.thursday:
        return 'Thursday';
      case Weekday.friday:
        return 'Friday';
      case Weekday.saturday:
        return 'Saturday';
    }
  }

  /// Convert to backend API value (0-6, where 0 is Sunday)
  int toApiValue() => index;

  static Weekday fromApiValue(int value) => Weekday.values[value % 7];
}

/// A scheduled availability window (e.g., "Free on weekdays 9-5")
class AvailabilityWindow {
  final String id;
  final String name;
  final AvailabilityStatus status;
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final List<Weekday> weekdays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AvailabilityWindow({
    required this.id,
    required this.name,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.weekdays,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  AvailabilityWindow copyWith({
    String? id,
    String? name,
    AvailabilityStatus? status,
    String? startTime,
    String? endTime,
    List<Weekday>? weekdays,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AvailabilityWindow(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      weekdays: weekdays ?? this.weekdays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if this window is currently active based on current time
  bool isActiveNow() {
    if (!isActive) return false;

    final now = DateTime.now();
    final currentWeekday = Weekday.values[now.weekday % 7];

    if (!weekdays.contains(currentWeekday)) return false;

    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return currentTime.compareTo(startTime) >= 0 &&
        currentTime.compareTo(endTime) <= 0;
  }

  /// Get a formatted description of when this window is active
  String get scheduleDescription {
    final days = weekdays.map((w) => w.shortLabel).join(', ');
    return '$days $startTime - $endTime';
  }
}
