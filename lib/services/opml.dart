import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/models/podcast.dart';
import 'package:xml/xml.dart';

class OpmlService {
  static const String logName = "OpmlService";
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
      debug("Parsed OPML, found ${urls.length} URLs", name: logName);
    } catch (e) {
      debug("OPML parse error: $e", name: logName);
    }

    return urls.toSet().toList();
  }

  static String generateOpml(List<Podcast> subscriptions) {
    debug("Generating OPML for ${subscriptions.length} subscriptions",
        name: logName);
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
    debug("Starting OPML import", name: logName);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['opml', 'xml'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        debug("OPML import cancelled by user", name: logName);
        return '';
      }

      debug("OPML file picked: ${result.files.first.name}", name: logName);
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

      debug("Import results: $successCount success, $failedCount failed, $skippedCount skipped",
          name: logName);

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
      error("OPML import failed: $e", name: logName);
      return 'Import failed: $e';
    }
  }

  Future<String> exportOpml(List<Podcast> subscriptions) async {
    debug("Starting OPML export for ${subscriptions.length} subscriptions",
        name: logName);
    try {
      if (subscriptions.isEmpty) {
        debug("No subscriptions to export", name: logName);
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
          info("Exported ${subscriptions.length} feeds", name: logName);
          return 'Exported ${subscriptions.length} feeds';
        } else {
          debug("OPML export cancelled by user", name: logName);
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
          info("Exported ${subscriptions.length} feeds", name: logName);
          return 'Exported ${subscriptions.length} feeds';
        } else {
          debug("OPML export cancelled by user", name: logName);
          return '';
        }
      }
    } catch (e) {
      error("OPML export failed: $e", name: logName);
      return 'Export failed: $e';
    }
  }
}
