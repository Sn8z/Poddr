import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/core/external_links.dart';
import 'package:poddr/data/parsers/html_parser.dart';

class PoddrHTML extends StatelessWidget {
  final String html;
  final double fontSize;

  const PoddrHTML({
    super.key,
    required this.html,
    this.fontSize = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final widgets = HtmlParser.parse(
      html,
      onLinkTap: (url) async {
        await launchExternalUrl(url);
      },
    );

    if (widgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return DefaultTextStyle(
      style: TextStyle(
        color: theme.onSurface,
        fontSize: fontSize,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets.map((w) {
          if (w is Text) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text.rich(
                w.textSpan!,
                style: TextStyle(
                  color: theme.onSurface,
                  fontSize: fontSize,
                  height: 1.5,
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: w,
          );
        }).toList(),
      ),
    );
  }
}
