import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:poddr/models/podcast.dart';
import 'package:xml/xml.dart';

class OpmlService {
  static List<String> parseOpml(String xmlString) {
    final urls = <String>[];

    try {
      final document = XmlDocument.parse(xmlString);
      final outlines = document.findAllElements('outline');

      for (final outline in outlines) {
        final type = outline.getAttribute('type');
        final xmlUrl = outline.getAttribute('xmlUrl');
        final url = outline.getAttribute('url');

        if (type == 'rss' && xmlUrl != null) {
          urls.add(xmlUrl);
        } else if (xmlUrl != null && xmlUrl.startsWith('http')) {
          urls.add(xmlUrl);
        } else if (url != null && (url.contains('rss') || url.contains('feed'))) {
          urls.add(url);
        }
      }
    } catch (e) {
      debugPrint("OPML parse error: $e");
    }

    return urls.toSet().toList();
  }

  static String generateOpml(List<Podcast> subscriptions) {
    final builder = XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('opml', nest: () {
      builder.attribute('version', '2.0');
      builder.element('head', nest: () {
        builder.element('title', nest: 'Poddr Subscriptions');
        builder.element('dateCreated', nest: DateTime.now().toIso8601String());
      });
      builder.element('body', nest: () {
        for (final podcast in subscriptions) {
          builder.element('outline', nest: () {
            builder.attribute('type', 'rss');
            builder.attribute('text', podcast.title ?? '');
            builder.attribute('title', podcast.title ?? '');
            builder.attribute('xmlUrl', podcast.rss ?? '');
            if (podcast.description != null) {
              builder.attribute('description', podcast.description!);
            }
            if (podcast.image != null) {
              builder.attribute('htmlUrl', podcast.image!);
            }
          });
        }
      });
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }

  Future<String> importOpml(
    List<Podcast> existingSubscriptions,
    Future<bool> Function(String rss) addSubscription,
  ) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['opml', 'xml'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return '';
      }

      final file = result.files.first;
      final content = file.bytes;
      if (content == null) {
        return 'Could not read file';
      }

      final xmlString = String.fromCharCodes(content);
      final rssUrls = parseOpml(xmlString);

      if (rssUrls.isEmpty) {
        return 'No feeds found in OPML';
      }

      final existingRss = existingSubscriptions.map((p) => p.rss).toSet();
      final newRssUrls = rssUrls.where((rss) => !existingRss.contains(rss)).toList();

      if (newRssUrls.isEmpty) {
        return 'All feeds already subscribed';
      }

      int successCount = 0;
      for (final rss in newRssUrls) {
        final success = await addSubscription(rss);
        if (success) successCount++;
      }

      final failedCount = newRssUrls.length - successCount;
      final skippedCount = rssUrls.length - newRssUrls.length;

      if (failedCount > 0 && skippedCount > 0) {
        return 'Imported $successCount feeds ($failedCount failed, $skippedCount already subscribed)';
      } else if (failedCount > 0) {
        return 'Imported $successCount of ${newRssUrls.length} feeds ($failedCount failed)';
      } else if (skippedCount > 0) {
        return 'Imported $successCount feeds ($skippedCount already subscribed)';
      } else {
        return 'Imported $successCount feeds';
      }
    } catch (e) {
      return 'Import failed: $e';
    }
  }

  Future<String> exportOpml(List<Podcast> subscriptions) async {
    try {
      if (subscriptions.isEmpty) {
        return 'No subscriptions to export';
      }

      final opmlContent = generateOpml(subscriptions);
      final bytes = Uint8List.fromList(opmlContent.codeUnits);

      if (kIsWeb) {
        final result = await FilePicker.saveFile(
          dialogTitle: 'Save OPML file',
          fileName: 'poddr_export.opml',
          type: FileType.custom,
          allowedExtensions: ['opml'],
          bytes: bytes,
        );

        if (result != null) {
          return 'Exported ${subscriptions.length} feeds';
        } else {
          return '';
        }
      } else {
        final result = await FilePicker.saveFile(
          dialogTitle: 'Save OPML file',
          fileName: 'poddr_export.opml',
          type: FileType.custom,
          allowedExtensions: ['opml'],
        );

        if (result != null) {
          final file = File(result);
          await file.writeAsString(opmlContent);
          return 'Exported ${subscriptions.length} feeds';
        } else {
          return '';
        }
      }
    } catch (e) {
      return 'Export failed: $e';
    }
  }
}
