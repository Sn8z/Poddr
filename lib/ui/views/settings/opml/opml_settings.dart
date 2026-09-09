import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:provider/provider.dart';
import 'package:poddr/ui/views/settings/opml/opml_view_model.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_progress.dart';

class OpmlSection extends StatelessWidget {
  const OpmlSection({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionsProvider = context.read<SubscriptionProvider>();

    return ChangeNotifierProvider(
      create: (_) => OpmlViewModel(subscriptionsProvider),
      builder: (context, child) {
        return const _OpmlView();
      },
    );
  }
}

class _OpmlView extends StatelessWidget {
  const _OpmlView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OpmlViewModel>();
    final isLoading = viewModel.isLoading;
    final statusMessage = viewModel.statusMessage;
    final importProgress = viewModel.importProgress;

    return Column(
      children: [
        if (importProgress != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: PoddrLinearProgress(
              value: importProgress,
              height: 2,
            ),
          ),
        PoddrListItem(
          leading: HugeIcon(
            icon: HugeIcons.strokeRoundedFileImport,
            color: context.theme.onSurface,
          ),
          title: isLoading ? 'Cancel import' : 'Import',
          onTap: () {
            if (isLoading) {
              viewModel.cancelImport();
            } else {
              _importWithConfirm(context, viewModel);
            }
          },
        ),
        PoddrListItem(
          leading: HugeIcon(
            icon: HugeIcons.strokeRoundedFileExport,
            color: context.theme.onSurface,
          ),
          title: 'Export',
          onTap: isLoading ? null : () => viewModel.exportOpml(),
        ),
        if (statusMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              statusMessage,
              style: context.theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Future<void> _importWithConfirm(
      BuildContext context, OpmlViewModel viewModel) async {
    if (!await viewModel.prepareImport()) return;
    if (!context.mounted) return;
    final newCount = viewModel.pendingNewCount;
    if (newCount == null) return;
    final skipped = viewModel.pendingSkippedCount;
    final confirmed = await showPoddrDialog<bool>(
      context: context,
      builder: (dialogContext) => PoddrDialog(
        header: Text(
          'Import $newCount feed${newCount == 1 ? '' : 's'}?',
          style: dialogContext.theme.textTheme.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: dialogContext.theme.secondary,
          ),
        ),
        actions: [
          PoddrTextButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          PoddrTextButton(
            label: 'Import',
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
        showCloseButton: true,
        child: Text(
          skipped > 0
              ? '$skipped skipped (already subscribed or duplicate).'
              : 'All feeds are new.',
          style: dialogContext.theme.textTheme.bodyMedium.copyWith(
            color: dialogContext.theme.onSurfaceVariant,
          ),
        ),
      ),
    );
    if (confirmed == true) {
      await viewModel.runPendingImport();
    } else {
      viewModel.dismissPendingImport();
    }
  }
}
