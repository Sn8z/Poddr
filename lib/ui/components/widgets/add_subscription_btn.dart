import 'package:flutter/material.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:provider/provider.dart';

class PoddrAddSubscriptionBtn extends StatelessWidget {
  final String? rss;
  final double size;

  const PoddrAddSubscriptionBtn({
    super.key,
    this.rss,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (rss == null) return const SizedBox.shrink();
    final subcriptions =
        context.select((SubscriptionProvider p) => p.subscriptions);
    final isSubscription = subcriptions.any((podcast) => podcast.rss == rss);

    return IconButton(
      icon: Icon(
        isSubscription ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: size,
        color: isSubscription
            ? context.theme.primary
            : context.theme.onSurfaceVariant,
      ),
      onPressed: () {
        final subscriptionProvider = context.read<SubscriptionProvider>();

        if (isSubscription) {
          final podcast =
              subcriptions.firstWhere((podcast) => podcast.rss == rss);
          subscriptionProvider.removeSubscription(podcast.rss ?? '');
        } else {
          subscriptionProvider.addSubscription(rss: rss!);
        }
      },
    );
  }
}
