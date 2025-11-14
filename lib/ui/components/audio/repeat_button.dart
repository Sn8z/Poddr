import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:poddr/services/media.dart';
import 'package:provider/provider.dart';

class RepeatButton extends StatelessWidget {
  final double size;

  const RepeatButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final repeatMode = context
        .select<MediaProvider, AudioServiceRepeatMode>((e) => e.repeatMode);

    IconData icon;
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        icon = Icons.repeat_sharp;
        break;
      case AudioServiceRepeatMode.one:
        icon = Icons.repeat_one_rounded;
        break;
      case AudioServiceRepeatMode.all:
        icon = Icons.repeat_rounded;
        break;
      default:
        icon = Icons.repeat_sharp;
        break;
    }

    final color = repeatMode != AudioServiceRepeatMode.none
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onInverseSurface;

    return IconButton(
      icon: Icon(icon, size: size),
      color: color,
      onPressed: () {
        context.read<MediaProvider>().cycleRepeatMode();
      },
      iconSize: size,
    );
  }
}
