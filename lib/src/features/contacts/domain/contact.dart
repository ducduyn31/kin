enum AvailabilityStatus {
  available,
  busy,
  away,
  offline,
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
