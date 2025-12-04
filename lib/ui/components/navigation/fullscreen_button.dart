import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FullscreenButton extends StatelessWidget {
  final double size;
  const FullscreenButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.push('/player');
      },
      icon: Icon(
        Icons.fullscreen_rounded,
        color: Theme.of(context).colorScheme.onSurface,
        size: size,
      ),
    );
  }
}
