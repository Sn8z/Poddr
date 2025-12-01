import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

class PoddrShortcuts extends StatelessWidget {
  final Widget child;

  const PoddrShortcuts({super.key, required this.child});

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
          context.go('/podcasts');
        },
        const SingleActivator(LogicalKeyboardKey.digit2, control: true): () {
          context.go('/local');
        },
        const SingleActivator(LogicalKeyboardKey.digit3, control: true): () {
          context.go('/library');
        },
        const SingleActivator(LogicalKeyboardKey.digit4, control: true): () {
          context.go('/search');
        },
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          context.go('/search');
        },
        const SingleActivator(LogicalKeyboardKey.digit5, control: true): () {
          context.go('/settings');
        },
      },
      child: child,
    );
  }
}
