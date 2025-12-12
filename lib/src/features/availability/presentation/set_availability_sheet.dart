import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/availability_status.dart';
import '../domain/availability.dart';

/// Bottom sheet for setting user's availability status
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

  /// Show the sheet as a modal bottom sheet
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
                    'Set Your Status',
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
                  labelText: 'Status message (optional)',
                  hintText: 'What are you up to?',
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
                'Duration',
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
                    label: Text(duration.label),
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
                  widget.onSave?.call(
                    _selectedStatus,
                    _messageController.text.isEmpty
                        ? null
                        : _messageController.text,
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
                      Text('Set as ${_selectedStatus.label}'),
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
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  String get _description {
    switch (status) {
      case AvailabilityStatus.free:
        return 'Ready to chat or call';
      case AvailabilityStatus.busy:
        return 'I\'m occupied right now';
      case AvailabilityStatus.doNotDisturb:
        return 'No notifications please';
      case AvailabilityStatus.sleeping:
        return 'Catching some Z\'s';
      case AvailabilityStatus.away:
        return 'Away from my phone';
      case AvailabilityStatus.offline:
        return 'Appear offline';
    }
  }

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
                      status.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                    Text(
                      _description,
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
