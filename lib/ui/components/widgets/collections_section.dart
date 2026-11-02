import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/models/collection.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/dialogs/poddr_collection_selection_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:provider/provider.dart';

class CollectionsSection extends StatelessWidget {
  const CollectionsSection({super.key, required this.rss});
  final String rss;

  @override
  Widget build(BuildContext context) {
    final isSubscribed = context.select<SubscriptionProvider, bool>(
      (p) => p.subscriptions.any((podcast) => podcast.rss == rss),
    );

    if (!isSubscribed) return const SizedBox.shrink();

    return _CollectionsForRss(rss: rss);
  }
}

class _CollectionsForRss extends StatefulWidget {
  const _CollectionsForRss({required this.rss});

  final String rss;

  @override
  State<_CollectionsForRss> createState() => _CollectionsForRssState();
}

class _CollectionsForRssState extends State<_CollectionsForRss> {
  late Stream<List<PodcastCollection>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _watch();
  }

  @override
  void didUpdateWidget(covariant _CollectionsForRss oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rss != widget.rss) {
      _stream = _watch();
    }
  }

  Stream<List<PodcastCollection>> _watch() =>
      context.read<CollectionsProvider>().watchCollectionsForRss(widget.rss);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PodcastCollection>>(
      stream: _stream,
      builder: (context, snapshot) {
        final collections = snapshot.data ?? [];
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (collections.isNotEmpty) ...[
              PoddrCollectionsDisplay(collections: collections),
              gapH8,
            ],
            PoddrCollectionEditButton(rss: widget.rss),
          ],
        );
      },
    );
  }
}

class PoddrCollectionEditButton extends StatelessWidget {
  const PoddrCollectionEditButton({super.key, required this.rss});
  final String rss;

  @override
  Widget build(BuildContext context) {
    return PoddrIconButton(
      icon: HugeIcon(icon: HugeIcons.strokeRoundedEdit01),
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
            child: PoddrCollectionSelectionDialog(rss: rss),
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
