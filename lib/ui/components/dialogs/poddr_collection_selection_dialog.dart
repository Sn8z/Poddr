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
        AsyncData(:final value) => _buildSelectionList(context, value),
      },
    );
  }

  Widget _buildSelectionList(
    BuildContext context,
    List<PodcastCollection> allCollections,
  ) {
    if (allCollections.isEmpty) {
      return Text(
        'No collections found. Create one in settings.',
        style: context.theme.textTheme.bodyMedium,
      );
    }

    return _CollectionToggles(
      subscriptionId: subscriptionId,
      collections: allCollections,
    );
  }
}

class _CollectionToggles extends StatefulWidget {
  const _CollectionToggles({
    required this.subscriptionId,
    required this.collections,
  });

  final int subscriptionId;
  final List<PodcastCollection> collections;

  @override
  State<_CollectionToggles> createState() => _CollectionTogglesState();
}

class _CollectionTogglesState extends State<_CollectionToggles> {
  late Stream<List<PodcastCollection>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _watch();
  }

  @override
  void didUpdateWidget(covariant _CollectionToggles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subscriptionId != widget.subscriptionId) {
      _stream = _watch();
    }
  }

  Stream<List<PodcastCollection>> _watch() => context
      .read<CollectionsProvider>()
      .watchCollectionsForSubscription(widget.subscriptionId);

  @override
  Widget build(BuildContext context) {
    final collectionsProvider = context.read<CollectionsProvider>();

    return StreamBuilder<List<PodcastCollection>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'The selected collections could not be loaded.',
            style: context.theme.textTheme.bodyMedium.copyWith(
              color: context.theme.onSurfaceVariant,
            ),
          );
        }

        final currentCollections = snapshot.data ?? [];
        return Column(
          children: widget.collections.map((collection) {
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
                        widget.subscriptionId, collection.id)
                    : await collectionsProvider
                        .removeSubscriptionFromCollection(
                            widget.subscriptionId, collection.id);
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
