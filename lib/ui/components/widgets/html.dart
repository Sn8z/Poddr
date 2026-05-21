import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/data/parsers/html_parser.dart';
import 'package:url_launcher/url_launcher.dart';

class PoddrHTML extends StatelessWidget {
  static const String logName = "PoddrHTML";
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
        final uri = Uri.tryParse(url);
        if (uri == null) return;
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          error(e.toString(), name: logName, error: e);
        }
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
