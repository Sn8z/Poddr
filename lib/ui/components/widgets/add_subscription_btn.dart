import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:provider/provider.dart';

class PoddrAddSubscriptionBtn extends StatelessWidget {
  final String? rss;
  final double size;

  const PoddrAddSubscriptionBtn({
    super.key,
    this.rss,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (rss == null) return const SizedBox.shrink();
    final subcriptions =
        context.select((SubscriptionProvider p) => p.subscriptions);
    final isSubscription = subcriptions.any((podcast) => podcast.rss == rss);

    return PoddrIconButton(
      icon: Icon(
        isSubscription ? LucideIcons.heart : LucideIcons.heartOff,
        size: size,
        color: isSubscription
            ? context.theme.secondary
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
      size: size,
    );
  }
}
