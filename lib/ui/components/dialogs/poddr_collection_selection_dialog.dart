import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/models/collection.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_progress.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:provider/provider.dart';

class PoddrCollectionSelectionDialog extends StatelessWidget {
  final int subscriptionId;

  const PoddrCollectionSelectionDialog(
      {super.key, required this.subscriptionId});

  @override
  Widget build(BuildContext context) {
    final collectionsProvider = context.read<CollectionsProvider>();

    return PoddrDialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collections',
              style: context.theme.textTheme.headlineSmall,
            ),
            gapH16,
            StreamBuilder<List<PodcastCollection>>(
              stream: collectionsProvider.collectionsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: PoddrSpinner());
                }
                final allCollections = snapshot.data ?? [];
                if (allCollections.isEmpty) {
                  return Text(
                      'No collections found. Create one in settings.',
                      style: context.theme.textTheme.bodyMedium);
                }
                return StreamBuilder<List<PodcastCollection>>(
                  stream: collectionsProvider
                      .watchCollectionsForSubscription(subscriptionId),
                  builder: (context, subSnapshot) {
                    final currentCollections = subSnapshot.data ?? [];
                    return Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: allCollections.map((collection) {
                            final isSelected = currentCollections
                                .any((c) => c.id == collection.id);
                            return _CollectionToggle(
                              name: collection.name,
                              color: Color(collection.color),
                              isSelected: isSelected,
                              onChanged: (value) {
                                if (value) {
                                  collectionsProvider
                                      .addSubscriptionToCollection(
                                          subscriptionId, collection.id);
                                } else {
                                  collectionsProvider
                                      .removeSubscriptionFromCollection(
                                          subscriptionId, collection.id);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionToggle extends StatelessWidget {
  final String name;
  final Color color;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const _CollectionToggle({
    required this.name,
    required this.color,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name, style: context.theme.textTheme.bodyMedium),
            ),
            Container(
              width: 40,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.theme.primary
                    : context.theme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment:
                        isSelected ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
