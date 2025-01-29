import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/providers/media.dart';
import 'package:provider/provider.dart';

class PoddrShortcuts extends StatelessWidget {
  const PoddrShortcuts({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () {
          context.read<MediaProvider>().playOrPause();
        },
        const SingleActivator(LogicalKeyboardKey.digit1, control: true): () {
          context.go('/');
        },
        const SingleActivator(LogicalKeyboardKey.digit2, control: true): () {
          context.go('/radio');
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
        // const SingleActivator(LogicalKeyboardKey.arrowUp, control: true): () {
        //   context.read<MediaProvider>().raiseVolume();
        // },
        // const SingleActivator(LogicalKeyboardKey.arrowUp, control: true): () {
        //   context.read<MediaProvider>().lowerVolume();
        // },
        // const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true): () {
        //   context.read<MediaProvider>().jumpBack();
        // },
        // const SingleActivator(LogicalKeyboardKey.arrowRight, control: true): () {
        //   context.read<MediaProvider>().jumpForward();
        // },
      },
      child: child,
    );
  }
}
