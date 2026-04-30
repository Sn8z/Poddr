import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

class PoddrShortcuts extends StatelessWidget {
  final Widget child;
  final GoRouter router;

  const PoddrShortcuts({
    super.key,
    required this.child,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () {
          context.read<MediaProvider>().playOrPause();
        },
        const SingleActivator(LogicalKeyboardKey.mediaPlayPause): () {
          context.read<MediaProvider>().playOrPause();
        },
        const SingleActivator(LogicalKeyboardKey.mediaPlay): () {
          context.read<MediaProvider>().play();
        },
        const SingleActivator(LogicalKeyboardKey.mediaPause): () {
          context.read<MediaProvider>().pause();
        },
        const SingleActivator(LogicalKeyboardKey.digit1, control: true): () {
          router.go('/podcasts');
        },
        const SingleActivator(LogicalKeyboardKey.digit2, control: true): () {
          router.go('/library');
        },
        const SingleActivator(LogicalKeyboardKey.digit3, control: true): () {
          router.go('/search');
        },
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          router.go('/search');
        },
        const SingleActivator(LogicalKeyboardKey.digit4, control: true): () {
          router.go('/settings');
        },
        const SingleActivator(LogicalKeyboardKey.arrowUp, control: true): () {
          context.read<MediaProvider>().increaseVolume();
        },
        const SingleActivator(LogicalKeyboardKey.arrowDown, control: true): () {
          context.read<MediaProvider>().decreaseVolume();
        },
      },
      child: child,
    );
  }
}
