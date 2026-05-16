import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:provider/provider.dart';
import 'package:poddr/ui/views/settings/opml/opml_view_model.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';

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

    return Column(
      children: [
        PoddrListItem(
          leading: const Icon(LucideIcons.arrowRightCircle),
          title: 'Import',
          onTap: isLoading ? null : () => viewModel.importOpml(),
        ),
        PoddrListItem(
          leading: const Icon(LucideIcons.arrowLeftCircle),
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
}
