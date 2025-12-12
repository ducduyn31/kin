import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routing/app_router.dart';
import '../domain/invitation_preview.dart';

/// Screen for joining a circle via invitation code
class JoinCircleScreen extends ConsumerStatefulWidget {
  final String invitationCode;

  const JoinCircleScreen({super.key, required this.invitationCode});

  @override
  ConsumerState<JoinCircleScreen> createState() => _JoinCircleScreenState();
}

class _JoinCircleScreenState extends ConsumerState<JoinCircleScreen> {
  bool _isLoadingPreview = true;
  bool _isJoining = false;
  String? _errorMessage;
  InvitationPreview? _preview;

  @override
  void initState() {
    super.initState();
    _loadInvitationPreview();
  }

  Future<void> _loadInvitationPreview() async {
    if (widget.invitationCode.isEmpty) {
      setState(() {
        _isLoadingPreview = false;
        _errorMessage = 'invalidInvitationCode';
      });
      return;
    }

    try {
      // TODO: Replace with actual API call
      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Mock preview data
      setState(() {
        _isLoadingPreview = false;
        _preview = const InvitationPreview(
          circleId: 'mock-circle-id',
          circleName: 'Sample Circle',
          circleDescription: 'A circle for testing',
          memberCount: 5,
          inviterId: 'mock-inviter-id',
          inviterName: 'John Doe',
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingPreview = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _joinCircle() async {
    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual API call
      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Show success message using global scaffold messenger
      final l10n = AppLocalizations.of(context)!;
      final joinedName = _preview?.circleName ?? l10n.circle;
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.joinedCircle(joinedName))),
      );

      // Navigate to circles tab
      final navigator = Navigator.of(context);
      navigator.pushNamedAndRemoveUntil(AppRouter.circles, (route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isJoining = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.joinCircle)),
      body: _isLoadingPreview
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState(colorScheme, l10n)
          : _buildPreviewState(theme, colorScheme, l10n),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme, AppLocalizations l10n) {
    final errorText = _errorMessage == 'invalidInvitationCode'
        ? l10n.invalidInvitationCode
        : _errorMessage!;
    return Semantics(
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                excludeSemantics: true,
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.unableToJoin,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _retry, child: Text(l10n.tryAgain)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _retry() {
    setState(() {
      _isLoadingPreview = true;
      _errorMessage = null;
    });
    _loadInvitationPreview();
  }

  Widget _buildPreviewState(
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final preview = _preview!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          // Circle avatar
          Semantics(
            excludeSemantics: true,
            child: CircleAvatar(
              radius: 48,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                preview.circleName.isNotEmpty
                    ? preview.circleName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Circle name
          Text(
            preview.circleName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (preview.circleDescription != null) ...[
            const SizedBox(height: 8),
            Text(
              preview.circleDescription!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                excludeSemantics: true,
                child: Icon(
                  Icons.people,
                  size: 18,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.membersCount(preview.memberCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Invited by
          Text(
            l10n.invitedBy(preview.inviterName),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const Spacer(),
          // Join button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isJoining ? null : _joinCircle,
              icon: _isJoining
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.group_add),
              label: Text(l10n.joinCircle),
            ),
          ),
          const SizedBox(height: 12),
          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
