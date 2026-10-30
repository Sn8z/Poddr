import 'package:flutter/widgets.dart';
import 'package:poddr/core/async_state.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/models/collection.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/ui/components/widgets/error_state.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_error_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_progress.dart';
import 'package:poddr/ui/components/widgets/poddr_toggle.dart';
import 'package:provider/provider.dart';

class PoddrCollectionSelectionDialog extends StatelessWidget {
  final int subscriptionId;

  const PoddrCollectionSelectionDialog({
    super.key,
    required this.subscriptionId,
  });

  @override
  Widget build(BuildContext context) {
    final collectionsProvider = context.watch<CollectionsProvider>();

    return PoddrDialog(
      header: Text(
        'Collections',
        style: context.theme.textTheme.headlineSmall,
      ),
      child: switch (collectionsProvider.collectionsState) {
        AsyncInitial() || AsyncLoading() => const Center(
            child: PoddrSpinner(),
          ),
        AsyncError(:final message) => ErrorState(
            message: message,
            onRetry: collectionsProvider.loadCollections,
          ),
        AsyncData(:final value) => _buildSelectionList(
            context,
            collectionsProvider,
            value,
          ),
      },
    );
  }

  Widget _buildSelectionList(
    BuildContext context,
    CollectionsProvider collectionsProvider,
    List<PodcastCollection> allCollections,
  ) {
    if (allCollections.isEmpty) {
      return Text(
        'No collections found. Create one in settings.',
        style: context.theme.textTheme.bodyMedium,
      );
    }

    return StreamBuilder<List<PodcastCollection>>(
      stream:
          collectionsProvider.watchCollectionsForSubscription(subscriptionId),
      builder: (context, subSnapshot) {
        if (subSnapshot.hasError) {
          return Text(
            'The selected collections could not be loaded.',
            style: context.theme.textTheme.bodyMedium.copyWith(
              color: context.theme.onSurfaceVariant,
            ),
          );
        }

        final currentCollections = subSnapshot.data ?? [];
        return Column(
          children: allCollections.map((collection) {
            final isSelected =
                currentCollections.any((c) => c.id == collection.id);
            return PoddrToggle(
              label: collection.name,
              leading: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Color(collection.color),
                  shape: BoxShape.circle,
                ),
              ),
              value: isSelected,
              onChanged: (value) async {
                final success = value
                    ? await collectionsProvider.addSubscriptionToCollection(
                        subscriptionId, collection.id)
                    : await collectionsProvider
                        .removeSubscriptionFromCollection(
                            subscriptionId, collection.id);
                if (!success && context.mounted) {
                  await showPoddrErrorDialog(
                    context: context,
                    message: collectionsProvider.lastError ??
                        'The collection could not be updated. '
                            'Please try again.',
                  );
                }
              },
            );
          }).toList(),
        );
      },
    );
  }
}
