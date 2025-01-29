import 'package:flutter/material.dart';
import 'package:poddr/utils/string_converter.dart';
import 'package:provider/provider.dart';
import 'package:poddr/providers/media.dart';

class DurationText extends StatelessWidget {
  const DurationText({super.key});

  @override
  Widget build(BuildContext context) {
    Duration duration =
        context.select<MediaProvider, Duration>((e) => e.duration);
    return Text(
      convertDurationToString(duration),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
      ),
    );
  }
}
