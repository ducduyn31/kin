import 'package:flutter/material.dart';
import '../../domain/contact.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback? onCall;

  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: contact.status.color,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.surface, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        contact.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        contact.statusMessage ?? contact.status.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
      trailing: contact.status == AvailabilityStatus.available
          ? IconButton(
              icon: Icon(Icons.call, color: theme.colorScheme.primary),
              onPressed: onCall,
            )
          : null,
    );
  }
}
