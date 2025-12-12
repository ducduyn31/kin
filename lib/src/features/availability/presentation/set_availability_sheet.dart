import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/src/l10n/app_localizations.dart';
import '../domain/availability_status.dart';
import '../domain/availability.dart';

String getAvailabilityDurationLabel(
  AvailabilityDuration duration,
  AppLocalizations l10n,
) {
  switch (duration) {
    case AvailabilityDuration.indefinite:
      return l10n.availabilityDurationIndefinite;
    case AvailabilityDuration.thirtyMinutes:
      return l10n.availabilityDurationThirtyMinutes;
    case AvailabilityDuration.oneHour:
      return l10n.availabilityDurationOneHour;
    case AvailabilityDuration.fourHours:
      return l10n.availabilityDurationFourHours;
    case AvailabilityDuration.untilTomorrow:
      return l10n.availabilityDurationUntilTomorrow;
  }
}

String getStatusDescription(AvailabilityStatus status, AppLocalizations l10n) {
  switch (status) {
    case AvailabilityStatus.free:
      return l10n.statusDescriptionFree;
    case AvailabilityStatus.busy:
      return l10n.statusDescriptionBusy;
    case AvailabilityStatus.doNotDisturb:
      return l10n.statusDescriptionDoNotDisturb;
    case AvailabilityStatus.sleeping:
      return l10n.statusDescriptionSleeping;
    case AvailabilityStatus.away:
      return l10n.statusDescriptionAway;
    case AvailabilityStatus.offline:
      return l10n.statusDescriptionOffline;
  }
}

String getStatusLabel(AvailabilityStatus status, AppLocalizations l10n) {
  switch (status) {
    case AvailabilityStatus.free:
      return l10n.statusLabelFree;
    case AvailabilityStatus.busy:
      return l10n.statusLabelBusy;
    case AvailabilityStatus.doNotDisturb:
      return l10n.statusLabelDoNotDisturb;
    case AvailabilityStatus.sleeping:
      return l10n.statusLabelSleeping;
    case AvailabilityStatus.away:
      return l10n.statusLabelAway;
    case AvailabilityStatus.offline:
      return l10n.statusLabelOffline;
  }
}

String getStatusLabelLowercase(
  AvailabilityStatus status,
  AppLocalizations l10n,
) {
  switch (status) {
    case AvailabilityStatus.free:
      return l10n.statusLabelFreeLowercase;
    case AvailabilityStatus.busy:
      return l10n.statusLabelBusyLowercase;
    case AvailabilityStatus.doNotDisturb:
      return l10n.statusLabelDoNotDisturbLowercase;
    case AvailabilityStatus.sleeping:
      return l10n.statusLabelSleepingLowercase;
    case AvailabilityStatus.away:
      return l10n.statusLabelAwayLowercase;
    case AvailabilityStatus.offline:
      return l10n.statusLabelOfflineLowercase;
  }
}

class SetAvailabilitySheet extends ConsumerStatefulWidget {
  final AvailabilityStatus? currentStatus;
  final String? currentStatusMessage;
  final Function(
    AvailabilityStatus status,
    String? message,
    AvailabilityDuration duration,
  )?
  onSave;

  const SetAvailabilitySheet({
    super.key,
    this.currentStatus,
    this.currentStatusMessage,
    this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    AvailabilityStatus? currentStatus,
    String? currentStatusMessage,
    Function(
      AvailabilityStatus status,
      String? message,
      AvailabilityDuration duration,
    )?
    onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SetAvailabilitySheet(
        currentStatus: currentStatus,
        currentStatusMessage: currentStatusMessage,
        onSave: onSave,
      ),
    );
  }

  @override
  ConsumerState<SetAvailabilitySheet> createState() =>
      _SetAvailabilitySheetState();
}

class _SetAvailabilitySheetState extends ConsumerState<SetAvailabilitySheet> {
  late AvailabilityStatus _selectedStatus;
  late TextEditingController _messageController;
  AvailabilityDuration _selectedDuration = AvailabilityDuration.indefinite;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus ?? AvailabilityStatus.free;
    _messageController = TextEditingController(
      text: widget.currentStatusMessage,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.setYourStatus,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status options
              ...AvailabilityStatus.values
                  .where((s) => s != AvailabilityStatus.offline)
                  .map(
                    (status) => _StatusOption(
                      status: status,
                      isSelected: _selectedStatus == status,
                      label: getStatusLabel(status, l10n),
                      description: getStatusDescription(status, l10n),
                      onTap: () {
                        setState(() {
                          _selectedStatus = status;
                        });
                      },
                    ),
                  ),

              const SizedBox(height: 24),

              // Status message input
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: l10n.statusMessageOptional,
                  hintText: l10n.statusMessageHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit_note),
                  suffixIcon: _messageController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _messageController.clear();
                            });
                          },
                        )
                      : null,
                ),
                maxLength: 100,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Duration selector
              Text(
                l10n.duration,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AvailabilityDuration.values.map((duration) {
                  final isSelected = _selectedDuration == duration;
                  return ChoiceChip(
                    label: Text(getAvailabilityDurationLabel(duration, l10n)),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedDuration = duration;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Save button
              FilledButton(
                onPressed: () {
                  final trimmed = _messageController.text.trim();
                  widget.onSave?.call(
                    _selectedStatus,
                    trimmed.isEmpty ? null : trimmed,
                    _selectedDuration,
                  );
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_selectedStatus.icon, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.setAsStatus(getStatusLabel(_selectedStatus, l10n)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final AvailabilityStatus status;
  final bool isSelected;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.isSelected,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(status.icon, color: status.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.8,
                              )
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: colorScheme.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
