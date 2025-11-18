import 'package:flutter/material.dart';
import 'package:poddr/services/media.dart';
import 'package:provider/provider.dart';

class SkipButton extends StatelessWidget {
  final double size;

  const SkipButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final bool canGoNext = context.select<MediaProvider, bool>(
      (provider) => provider.canGoNext,
    );

    return MouseRegion(
      cursor: canGoNext ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () {
          canGoNext ? context.read<MediaProvider>().skipToNext() : null;
        },
        child: SizedBox.fromSize(
          size: Size.square(size),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Icon(
                  Icons.skip_next_rounded,
                  size: size * 0.8,
                  color: canGoNext
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
