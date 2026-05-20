import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/models/collection.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/dialogs/poddr_collection_selection_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:provider/provider.dart';

class CollectionsSection extends StatelessWidget {
  const CollectionsSection({super.key, required this.rss});
  final String rss;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: context.read<SubscriptionProvider>().watchSubscriptionId(rss),
      builder: (context, subSnapshot) {
        if (subSnapshot.connectionState == ConnectionState.waiting &&
            !subSnapshot.hasData) {
          return const ShimmerBox(height: 20);
        }

        final subscriptionId = subSnapshot.data;
        if (subscriptionId == null) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<List<PodcastCollection>>(
          stream: context
              .read<CollectionsProvider>()
              .watchCollectionsForSubscription(subscriptionId),
          builder: (context, colSnapshot) {
            final collections = colSnapshot.data ?? [];
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (collections.isNotEmpty) ...[
                  PoddrCollectionsDisplay(collections: collections),
                  gapH8,
                ],
                PoddrCollectionEditButton(subscriptionId: subscriptionId),
              ],
            );
          },
        );
      },
    );
  }
}

class PoddrCollectionEditButton extends StatelessWidget {
  const PoddrCollectionEditButton({super.key, required this.subscriptionId});
  final int subscriptionId;

  @override
  Widget build(BuildContext context) {
    return PoddrIconButton(
      icon: Icon(LucideIcons.edit),
      onPressed: () {
        showPoddrDialog(
          context: context,
          builder: (context) => PoddrDialog(
            header: Text(
              'Add to Collection',
              style: context.theme.textTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: context.theme.secondary,
              ),
            ),
            child: PoddrCollectionSelectionDialog(
              subscriptionId: subscriptionId,
            ),
          ),
        );
      },
    );
  }
}

class PoddrCollectionsDisplay extends StatelessWidget {
  const PoddrCollectionsDisplay({super.key, required this.collections});
  final List<PodcastCollection> collections;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children:
          collections.map((c) => PoddrCollectionChip(collection: c)).toList(),
    );
  }
}

class PoddrCollectionChip extends StatelessWidget {
  const PoddrCollectionChip({super.key, required this.collection});
  final PodcastCollection collection;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(collection.color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        collection.name,
        style: context.theme.textTheme.labelMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: context.theme.onPrimary,
        ),
      ),
    );
  }
}
