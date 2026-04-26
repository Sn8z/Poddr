import 'package:flutter/material.dart';
import 'package:poddr/models/collection.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/ui/components/widgets/dialog.dart';
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
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Collections',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              gapH16,
              StreamBuilder<List<PodcastCollection>>(
                stream: collectionsProvider.collectionsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final allCollections = snapshot.data ?? [];
                  if (allCollections.isEmpty) {
                    return const Text(
                        'No collections found. Create one in settings.');
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
                              return SwitchListTile(
                                title: Text(collection.name),
                                secondary: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Color(collection.color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                value: isSelected,
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
      ],
    );
  }
}
