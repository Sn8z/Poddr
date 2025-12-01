import 'package:flutter/material.dart';
import 'package:poddr/services/media/media_provider.dart';
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
              Center(
                child: Icon(
                  Icons.skip_previous_rounded,
                  size: size * 0.8,
                  color: canGoPrevious
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
