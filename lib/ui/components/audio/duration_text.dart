import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/utils/string_converter.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

class DurationText extends StatelessWidget {
  const DurationText({super.key});

  @override
  Widget build(BuildContext context) {
    Duration duration =
        context.select<MediaProvider, Duration>((e) => e.duration);
    return Text(
      convertDurationToString(duration),
      style: context.theme.textTheme.labelMedium,
    );
  }
}
