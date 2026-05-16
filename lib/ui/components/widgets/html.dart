import 'package:flutter/material.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:poddr/core/log.dart';

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
    String cleanHtml = html
        .replaceAll(RegExp(r"\s*style='[^']*'", caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*style="[^"]*"', caseSensitive: false), '');

    return Html(
      data: cleanHtml,
      style: {
        "html": Style(
          color: context.theme.onSurface,
          fontSize: FontSize(fontSize),
        ),
        "p": Style(
          margin: Margins.only(bottom: 12.0),
        ),
        "a": Style(
          color: context.theme.primary,
          textDecoration: TextDecoration.underline,
        ),
        "ul": Style(
          margin: Margins.only(left: 16, bottom: 12),
        ),
        "li": Style(
          margin: Margins.only(bottom: 6),
        ),
      },
      onlyRenderTheseTags: {
        "html",
        "body",
        "p",
        "a",
        "strong",
        "em",
        "ul",
        "ol",
        "li",
        "br",
      },
      shrinkWrap: true,
      onLinkTap: (url, attributes, element) async {
        if (url == null) return;

        final uri = Uri.tryParse(url);
        if (uri == null) return;

        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          error(e.toString(), name: "PoddrHTML", error: e);
        }
      },
    );
  }
}
