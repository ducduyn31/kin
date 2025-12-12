import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/contact_with_availability.dart';
import '../../../availability/domain/availability_status.dart';

/// Card widget displaying a contact with their availability status
class AvailabilityCard extends StatelessWidget {
  final ContactWithAvailability contact;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AvailabilityCard({
    super.key,
    required this.contact,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final displayName = contact.resolvedName ?? l10n.unknownContact;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar with status indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: contact.avatarUrl != null
                        ? NetworkImage(contact.avatarUrl!)
                        : null,
                    child: contact.avatarUrl == null
                        ? Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: AvailabilityStatusBadge(status: contact.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Name
              Text(
                displayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              // Status message or status label
              const SizedBox(height: 2),
              Text(
                contact.statusMessage ?? contact.status.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: contact.status.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small badge showing availability status
class AvailabilityStatusBadge extends StatelessWidget {
  final AvailabilityStatus status;
  final double size;

  /// Minimum size for the badge to ensure the icon remains readable
  static const double minSize = 10.0;

  const AvailabilityStatusBadge({
    super.key,
    required this.status,
    this.size = 16,
  }) : assert(size >= minSize, 'size must be at least $minSize');

  @override
  Widget build(BuildContext context) {
    final iconSize = (size - 6).clamp(4.0, double.infinity);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: status.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
      child: status == AvailabilityStatus.sleeping
          ? Icon(Icons.bedtime, size: iconSize, color: Colors.white)
          : null,
    );
  }
}
