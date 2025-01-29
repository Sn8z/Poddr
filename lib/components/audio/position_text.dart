import 'package:flutter/material.dart';
import 'package:poddr/utils/string_converter.dart';
import 'package:provider/provider.dart';
import 'package:poddr/providers/media.dart';

class PositionText extends StatelessWidget {
  const PositionText({super.key});

  @override
  Widget build(BuildContext context) {
    Duration position =
        context.select<MediaProvider, Duration>((e) => e.position);
    return Text(
      convertDurationToString(position),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
      ),
    );
  }
}
