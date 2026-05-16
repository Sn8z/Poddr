import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/utils/string_converter.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

class PositionText extends StatelessWidget {
  const PositionText({super.key});

  @override
  Widget build(BuildContext context) {
    Duration position =
        context.select<MediaProvider, Duration>((e) => e.position);
    return Text(
      convertDurationToString(position),
      style: TextStyle(
        color: context.theme.onSurface,
        fontSize: 14,
      ),
    );
  }
}
