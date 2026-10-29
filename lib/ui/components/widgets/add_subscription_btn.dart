import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/components/widgets/poddr_error_dialog.dart';
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
      icon: HugeIcon(
        icon: isSubscription
            ? HugeIcons.strokeRoundedHeartCheck
            : HugeIcons.strokeRoundedHeartAdd,
        size: size,
        strokeWidth: isSubscription ? 2 : 1,
        color: isSubscription
            ? context.theme.primary
            : context.theme.onSurfaceVariant,
      ),
      onPressed: () async {
        final subscriptionProvider = context.read<SubscriptionProvider>();
        final bool success;

        if (isSubscription) {
          final podcast =
              subcriptions.firstWhere((podcast) => podcast.rss == rss);
          success =
              await subscriptionProvider.removeSubscription(podcast.rss ?? '');
        } else {
          success = await subscriptionProvider.addSubscription(rss: rss!);
        }

        if (!success && context.mounted) {
          await showPoddrErrorDialog(
            context: context,
            title: isSubscription
                ? 'Could not unsubscribe'
                : 'Could not subscribe',
            message: subscriptionProvider.lastError ??
                'Something went wrong. Please try again.',
          );
        }
      },
      size: size,
    );
  }
}
