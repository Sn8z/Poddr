import 'package:flutter/material.dart';
import 'package:poddr/services/media.dart';
import 'package:provider/provider.dart';

class PreviousButton extends StatelessWidget {
  final double size;

  const PreviousButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final bool canGoPrevious = context.select<MediaProvider, bool>(
      (provider) => provider.canGoPrevious,
    );

    return MouseRegion(
      cursor:
          canGoPrevious ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () {
          canGoPrevious ? context.read<MediaProvider>().skipToPrevious() : null;
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
                  Icons.skip_previous_rounded,
                  color: canGoPrevious
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
