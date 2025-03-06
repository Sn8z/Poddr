import 'package:flutter/material.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:provider/provider.dart';

class PoddrAddSubscriptionBtn extends StatelessWidget {
  final String title;
  final String rss;
  final String description;
  final String author;
  final String image;
  final double size;

  const PoddrAddSubscriptionBtn({
    super.key,
    required this.title,
    required this.rss,
    required this.description,
    required this.author,
    required this.image,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final subcriptions =
        context.select((SubscriptionProvider p) => p.subscriptions);
    final isSubscription = subcriptions.any((podcast) => podcast.rss == rss);

    return IconButton(
      icon: Icon(
        isSubscription ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: size,
        color: isSubscription
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: () {
        final subscriptionProvider = context.read<SubscriptionProvider>();

        if (isSubscription) {
          final podcast =
              subcriptions.firstWhere((podcast) => podcast.rss == rss);
          subscriptionProvider.removeFavourite(podcast.rss ?? '');
        } else {
          subscriptionProvider.addFavourite(
            title: title,
            rss: rss,
            description: description,
            author: author,
            image: image,
          );
        }
      },
    );
  }
}
