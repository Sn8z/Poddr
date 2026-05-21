import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

typedef LinkTapCallback = void Function(String url);

class HtmlBlock {
  final HtmlBlockType type;
  final List<InlineSpan> spans;
  final List<HtmlBlock>? children;

  const HtmlBlock({
    required this.type,
    required this.spans,
    this.children,
  });
}

enum HtmlBlockType { paragraph, unorderedList, orderedList, listItem }

class HtmlParser {
  static List<Widget> parse(String html, {LinkTapCallback? onLinkTap, TextStyle? linkStyle}) {
    final cleaned = _stripUnsupportedTags(html);
    final blocks = _splitBlocks(cleaned);
    final widgets = <Widget>[];

    for (final block in blocks) {
      final widget = _parseBlock(block.trim(), onLinkTap, linkStyle);
      if (widget != null) {
        widgets.add(widget);
      }
    }

    return widgets;
  }

  static String _stripUnsupportedTags(String html) {
    return html.replaceAll(RegExp(r'<(?!/?\s*(?:p|a|strong|em|ul|ol|li|br|/p|/a|/strong|/em|/ul|/ol|/li|/br))[^>]*>', caseSensitive: false), '');
  }

  static List<String> _splitBlocks(String html) {
    final blocks = <String>[];
    final blockPattern = RegExp(r'(<(?:p|ul|ol)[^>]*>.*?</(?:p|ul|ol)>)', caseSensitive: false, dotAll: true);
    final matches = blockPattern.allMatches(html);

    if (matches.isEmpty) {
      if (html.trim().isNotEmpty) {
        blocks.add('<p>$html</p>');
      }
      return blocks;
    }

    int lastEnd = 0;
    for (final match in matches) {
      final before = html.substring(lastEnd, match.start).trim();
      if (before.isNotEmpty) {
        blocks.add('<p>$before</p>');
      }
      blocks.add(match.group(0)!);
      lastEnd = match.end;
    }

    final after = html.substring(lastEnd).trim();
    if (after.isNotEmpty) {
      blocks.add('<p>$after</p>');
    }

    return blocks;
  }

  static Widget? _parseBlock(String html, LinkTapCallback? onLinkTap, TextStyle? linkStyle) {
    final pMatch = RegExp(r'^<p[^>]*>(.*)</p>$', caseSensitive: false, dotAll: true).firstMatch(html.trim());
    if (pMatch != null) {
      final content = pMatch.group(1)!.trim();
      if (content.isEmpty) return null;
      return _buildParagraph(content, onLinkTap, linkStyle);
    }

    final ulMatch = RegExp(r'^<ul[^>]*>(.*)</ul>$', caseSensitive: false, dotAll: true).firstMatch(html.trim());
    if (ulMatch != null) {
      return _buildList(ulMatch.group(1)!, bullet: '\u2022', onLinkTap: onLinkTap, linkStyle: linkStyle);
    }

    final olMatch = RegExp(r'^<ol[^>]*>(.*)</ol>$', caseSensitive: false, dotAll: true).firstMatch(html.trim());
    if (olMatch != null) {
      return _buildList(olMatch.group(1)!, ordered: true, onLinkTap: onLinkTap, linkStyle: linkStyle);
    }

    return null;
  }

  static Widget _buildParagraph(String content, LinkTapCallback? onLinkTap, TextStyle? linkStyle) {
    final spans = _parseInline(content, onLinkTap, linkStyle);
    return Text.rich(
      TextSpan(children: spans),
      style: const TextStyle(height: 1.5),
    );
  }

  static Widget _buildList(String content, {String bullet = '\u2022', bool ordered = false, LinkTapCallback? onLinkTap, TextStyle? linkStyle}) {
    final items = <String>[];
    final liPattern = RegExp(r'<li[^>]*>(.*?)</li>', caseSensitive: false, dotAll: true);
    for (final match in liPattern.allMatches(content)) {
      items.add(match.group(1)!.trim());
    }

    if (items.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      final prefix = ordered ? '${i + 1}. ' : bullet;
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$prefix ', style: const TextStyle(height: 1.5)),
              Expanded(child: Text.rich(TextSpan(children: _parseInline(items[i], onLinkTap, linkStyle)))),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  static List<InlineSpan> _parseInline(String html, LinkTapCallback? onLinkTap, TextStyle? linkStyle) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(
      r'(<a[^>]*>.*?</a>|<strong>.*?</strong>|<em>.*?</em>|<br\s*/?>)',
      caseSensitive: false,
      dotAll: true,
    );

    int lastEnd = 0;
    for (final match in pattern.allMatches(html)) {
      final before = html.substring(lastEnd, match.start);
      if (before.isNotEmpty) {
        spans.add(TextSpan(text: _decodeEntities(before)));
      }

      final tag = match.group(0)!;
      if (tag.toLowerCase().startsWith('<a')) {
        final hrefMatch = RegExp(r'href="([^"]+)"', caseSensitive: false).firstMatch(tag)
            ?? RegExp(r"href='([^']+)'", caseSensitive: false).firstMatch(tag);
        final url = hrefMatch?.group(1);
        final inner = _extractInnerHtml(tag);
        spans.add(
          TextSpan(
            text: _decodeEntities(inner),
            style: linkStyle ?? const TextStyle(
              decoration: TextDecoration.underline,
            ),
            recognizer: url != null && onLinkTap != null
                ? (TapGestureRecognizer()..onTap = () => onLinkTap(url))
                : null,
          ),
        );
      } else if (tag.toLowerCase().startsWith('<strong')) {
        final inner = _extractInnerHtml(tag);
        spans.add(TextSpan(
          text: _decodeEntities(inner),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (tag.toLowerCase().startsWith('<em')) {
        final inner = _extractInnerHtml(tag);
        spans.add(TextSpan(
          text: _decodeEntities(inner),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else if (tag.toLowerCase().contains('<br')) {
        spans.add(const TextSpan(text: '\n'));
      }

      lastEnd = match.end;
    }

    final remaining = html.substring(lastEnd);
    if (remaining.isNotEmpty) {
      spans.add(TextSpan(text: _decodeEntities(remaining)));
    }

    return spans;
  }

  static String _extractInnerHtml(String tag) {
    final closeIndex = tag.indexOf('>');
    final lastCloseIndex = tag.lastIndexOf('<');
    if (closeIndex == -1 || lastCloseIndex <= closeIndex) return tag;
    return tag.substring(closeIndex + 1, lastCloseIndex);
  }

  static String _decodeEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      final code = int.tryParse(match.group(1)!);
      return code != null ? String.fromCharCode(code) : match.group(0)!;
    }).replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
      final code = int.tryParse(match.group(1)!, radix: 16);
      return code != null ? String.fromCharCode(code) : match.group(0)!;
    });
  }
}
