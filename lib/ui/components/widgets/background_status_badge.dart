import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/offline.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/services/sync.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/status_banner.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:provider/provider.dart';

/// Persistent global indicator for background failures that retries did not fix.
///
/// Renders nothing while there is nothing unresolved.
class BackgroundStatusBadge extends StatelessWidget {
  /// Whether the badge can show its label (desktop sidebar) or only the icon.
  final bool expanded;

  /// Full-width presentation used above the mobile bottom bar.
  final bool stretch;

  const BackgroundStatusBadge({
    super.key,
    this.expanded = false,
    this.stretch = false,
  });

  @override
  Widget build(BuildContext context) {
    final failedFeeds = context.select<SubscriptionProvider, int>(
      (provider) => provider.failedFeedCount,
    );
    final failedDownloads = context.select<OfflineProvider, int>(
      (provider) => provider.failedDownloadCount,
    );
    final hasSyncIssue = context.select<SyncProvider, bool>(
      (provider) => provider.hasEscalatedFailure,
    );

    final issueCount = failedFeeds + failedDownloads + (hasSyncIssue ? 1 : 0);
    if (issueCount == 0) return const SizedBox.shrink();

    final theme = context.theme;
    final label = issueCount == 1 ? '1 issue' : '$issueCount issues';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openPanel(context),
        child: Container(
          width: stretch ? double.infinity : null,
          margin: const EdgeInsets.all(8),
          padding: EdgeInsets.symmetric(
            horizontal: stretch ? 16 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: theme.tertiaryContainer.withAlpha(60),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.tertiary.withAlpha(80)),
          ),
          child: Row(
            mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment:
                stretch ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedAlertSquare,
                size: 18,
                color: theme.tertiary,
              ),
              if (expanded || stretch) ...[
                gapW8,
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium.copyWith(
                      color: theme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (stretch)
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 16,
                    color: theme.tertiary,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openPanel(BuildContext context) {
    showPoddrDialog<void>(
      context: context,
      builder: (dialogContext) {
        return PoddrDialog(
          header: Text(
            'Background issues',
            style: dialogContext.theme.textTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: dialogContext.theme.secondary,
            ),
          ),
          showCloseButton: true,
          child: const _BackgroundStatusPanel(),
        );
      },
    );
  }
}

class _BackgroundStatusPanel extends StatelessWidget {
  const _BackgroundStatusPanel();

  @override
  Widget build(BuildContext context) {
    final subscriptions = context.watch<SubscriptionProvider>();
    final offline = context.watch<OfflineProvider>();
    final sync = context.watch<SyncProvider>();

    final items = <Widget>[];

    if (sync.hasEscalatedFailure) {
      items.add(
        _StatusIssue(
          icon: HugeIcons.strokeRoundedDatabaseSync,
          message: sync.statusDescription ?? 'Sync is having trouble.',
          actionLabel: 'Settings',
          onAction: () {
            Navigator.of(context).pop();
            context.go('/settings');
          },
          severity: StatusSeverity.error,
        ),
      );
    }

    if (subscriptions.failedFeedCount > 0) {
      final count = subscriptions.failedFeedCount;
      items.add(
        _StatusIssue(
          icon: HugeIcons.strokeRoundedRss,
          message: count == 1
              ? '1 feed could not be refreshed.'
              : '$count feeds could not be refreshed.',
          actionLabel: 'Retry',
          onAction: () async {
            Navigator.of(context).pop();
            await subscriptions.retryFailedFeeds();
          },
          severity: StatusSeverity.warning,
        ),
      );
    }

    if (offline.failedDownloadCount > 0) {
      final count = offline.failedDownloadCount;
      items.add(
        _StatusIssue(
          icon: HugeIcons.strokeRoundedDownload01,
          message:
              count == 1 ? '1 download failed.' : '$count downloads failed.',
          actionLabel: 'Retry',
          onAction: () async {
            Navigator.of(context).pop();
            await offline.retryFailedDownloads();
          },
          severity: StatusSeverity.warning,
        ),
      );
    }

    if (items.isEmpty) {
      return Text(
        'Everything looks good.',
        style: context.theme.textTheme.bodyMedium.copyWith(
          color: context.theme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) gapH12,
          items[i],
        ],
      ],
    );
  }
}

class _StatusIssue extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final StatusSeverity severity;

  const _StatusIssue({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final color =
        severity == StatusSeverity.error ? theme.error : theme.tertiary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (severity == StatusSeverity.error
                ? theme.errorContainer
                : theme.tertiaryContainer)
            .withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          HugeIcon(icon: icon, size: 18, color: color),
          gapW12,
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall.copyWith(
                color: color,
                height: 1.4,
              ),
            ),
          ),
          gapW8,
          PoddrTextButton(
            label: actionLabel,
            color: color,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}
