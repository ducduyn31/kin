import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user.dart';
import '../../availability/domain/availability_status.dart';
import '../../availability/domain/availability.dart';

final userProvider = NotifierProvider<UserNotifier, User>(UserNotifier.new);

class UserNotifier extends Notifier<User> {
  @override
  User build() {
    return const User(
      id: 'current_user',
      name: 'John Doe',
      email: 'john.doe@example.com',
      avatarUrl: '',
      status: AvailabilityStatus.free,
      statusMessage: 'Working from home',
    );
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateStatus(AvailabilityStatus status) {
    state = state.copyWith(status: status);
  }

  void updateStatusMessage(String? message) {
    state = state.copyWith(statusMessage: message);
  }

  void setAvailability(
    AvailabilityStatus status,
    String? message,
    AvailabilityDuration duration,
  ) {
    state = state.copyWith(
      status: status,
      statusMessage: message,
      statusExpiresAt: duration.expiresAt,
    );
  }
}
