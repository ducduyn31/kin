import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../application/circles_provider.dart';
import 'widgets/circle_tile.dart';

class CirclesScreen extends ConsumerWidget {
  const CirclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final circles = ref.watch(circlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.circles),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Search circles
            },
          ),
        ],
      ),
      body: circles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No circles yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a circle or join one with an invite',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                // Circles list
                ...circles.map((circle) {
                  final freeCount = ref.watch(
                    circleFreeCountProvider(circle.id),
                  );
                  return CircleTile(
                    circle: circle,
                    freeCount: freeCount,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/circle',
                        arguments: circle.id,
                      );
                    },
                  );
                }),

                const Divider(height: 32),

                // Join circle option
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.link,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  title: const Text('Join a Circle'),
                  subtitle: const Text('Have an invite code? Tap to join.'),
                  onTap: () {
                    _showJoinCircleDialog(context);
                  },
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'circles_fab',
        onPressed: () {
          _showCreateCircleDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }

  void _showJoinCircleDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join a Circle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Invite code',
            hintText: 'Enter the invite code',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Join circle with code
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Joining circle... (mock)')),
              );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showCreateCircleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create a Circle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Circle name',
                hintText: 'e.g., Family, Close Friends',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'What is this circle about?',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Create circle
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Created "${nameController.text}" (mock)'),
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
