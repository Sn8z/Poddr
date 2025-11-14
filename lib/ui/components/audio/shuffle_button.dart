import 'package:flutter/material.dart';
import 'package:poddr/services/media.dart';
import 'package:provider/provider.dart';

class ShuffleButton extends StatelessWidget {
  final double size;

  const ShuffleButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final bool isShuffling =
        context.select<MediaProvider, bool>((e) => e.isShuffling);

    final icon = isShuffling ? Icons.shuffle_rounded : Icons.shuffle_outlined;

    final color = isShuffling
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onInverseSurface;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<MediaProvider>().cycleShuffleMode();
        },
        child: SizedBox.fromSize(
          size: Size.square(size),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
