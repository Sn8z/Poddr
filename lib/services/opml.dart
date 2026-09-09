import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/core/validators.dart';
import 'package:poddr/models/podcast.dart';
import 'package:xml/xml.dart';

class OpmlService {
  static const String logName = "OpmlService";
  static const int maxImportBytes = 5 * 1024 * 1024;
  static const int importBatchSize = 3;

  static List<String> parseOpml(String xmlString) {
    final urls = <String>[];
    final seen = <String>{};
    final document = XmlDocument.parse(xmlString);

    for (final outline in document.findAllElements('outline')) {
      final type = outline.getAttribute('type')?.toLowerCase();
      final xmlUrl = outline.getAttribute('xmlUrl') ??
          outline.getAttribute('xmlURL') ??
          outline.getAttribute('xmlurl');
      if (xmlUrl == null) continue;
      if (type != null && type != 'rss' && type != 'link') continue;
      final candidate = xmlUrl.trim();
      if (isValidUrl(candidate) && seen.add(normalizeFeedUrl(candidate))) {
        urls.add(candidate);
      }
    }

    return urls;
  }

  static String normalizeFeedUrl(String url) {
    final trimmed = url.trim();
    try {
      final uri = Uri.parse(trimmed);
      var path = uri.path;
      while (path.endsWith('/') && path.length > 1) {
        path = path.substring(0, path.length - 1);
      }
      if (path == '/') path = '';
      return uri.replace(host: uri.host.toLowerCase(), path: path).toString();
    } catch (_) {
      return trimmed;
    }
  }

  static String rfc822(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = date.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${weekdays[d.weekday - 1]}, ${two(d.day)} ${months[d.month - 1]} '
        '${d.year} ${two(d.hour)}:${two(d.minute)}:${two(d.second)} GMT';
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
        builder.element('dateCreated', nest: rfc822(DateTime.now()));
      });
      builder.element('body', nest: () {
        for (final podcast in subscriptions) {
          final rss = podcast.rss?.trim() ?? '';
          if (rss.isEmpty) continue;
          builder.element('outline', nest: () {
            builder.attribute('type', 'rss');
            builder.attribute('text', podcast.title ?? '');
            builder.attribute('title', podcast.title ?? '');
            builder.attribute('xmlUrl', rss);
            if (podcast.link != null && podcast.link!.isNotEmpty) {
              builder.attribute('htmlUrl', podcast.link!);
            }
            if (podcast.description != null) {
              builder.attribute('description', podcast.description!);
            }
          });
        }
      });
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }

  Future<({List<String> newUrls, int skippedCount, String? stopMessage})?>
      pickAndParse(List<Podcast> existingSubscriptions) async {
    debug("Starting OPML import", name: logName);
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: 'Import OPML file',
        type: FileType.custom,
        allowedExtensions: ['opml', 'xml'],
      );

      if (picked == null) {
        debug("OPML import cancelled by user", name: logName);
        return null;
      }

      final size = picked.lengthSync() ?? await picked.length();
      if (size > maxImportBytes) {
        error('OPML import rejected: file too large', name: logName);
        return (newUrls: <String>[], skippedCount: 0, stopMessage: 'File too large');
      }

      debug("OPML file picked: ${picked.name}", name: logName);
      final xmlString =
          utf8.decode(await picked.readAsBytes(), allowMalformed: true);

      List<String> rssUrls;
      try {
        rssUrls = parseOpml(xmlString);
      } catch (e) {
        error('OPML import failed: unparseable file', name: logName);
        debug('OPML parse detail: $e', name: logName);
        return (newUrls: <String>[], skippedCount: 0, stopMessage: 'Could not parse OPML file');
      }

      if (rssUrls.isEmpty) {
        return (newUrls: <String>[], skippedCount: 0, stopMessage: 'No feeds found in OPML');
      }

      final existingRss = {
        for (final p in existingSubscriptions)
          if (p.rss != null) normalizeFeedUrl(p.rss!),
      };
      final newRssUrls = [
        for (final rss in rssUrls)
          if (!existingRss.contains(normalizeFeedUrl(rss))) rss,
      ];

      if (newRssUrls.isEmpty) {
        return (newUrls: <String>[], skippedCount: rssUrls.length, stopMessage: 'All feeds already subscribed');
      }

      return (
        newUrls: newRssUrls,
        skippedCount: rssUrls.length - newRssUrls.length,
        stopMessage: null,
      );
    } catch (e) {
      error('OPML import failed', name: logName);
      debug('OPML import detail: $e', name: logName);
      return (newUrls: <String>[], skippedCount: 0, stopMessage: 'Import failed');
    }
  }

  Future<String> importUrls(
    List<String> newRssUrls,
    Future<bool> Function(String rss) addSubscription, {
    void Function(int done, int total)? onProgress,
    bool Function()? isCancelled,
  }) async {
    var completed = 0;
    var successCount = 0;
    for (var i = 0; i < newRssUrls.length; i += importBatchSize) {
      if (isCancelled?.call() ?? false) {
        debug("OPML import cancelled by user", name: logName);
        return 'Import cancelled';
      }
      final batch = newRssUrls.skip(i).take(importBatchSize);
      final results = await Future.wait(batch.map(addSubscription));
      successCount += results.where((r) => r).length;
      completed += batch.length;
      onProgress?.call(completed, newRssUrls.length);
    }

    final failedCount = newRssUrls.length - successCount;
    debug("Import results: $successCount success, $failedCount failed",
        name: logName);

    if (failedCount > 0) {
      return 'Imported $successCount of ${newRssUrls.length} feeds ($failedCount failed)';
    }
    return 'Imported $successCount feeds';
  }

  Future<String?> exportOpml(List<Podcast> subscriptions) async {
    debug("Starting OPML export for ${subscriptions.length} subscriptions",
        name: logName);
    try {
      final writable = subscriptions
          .where((p) => (p.rss?.trim() ?? '').isNotEmpty)
          .toList();
      if (writable.isEmpty) {
        debug("No subscriptions to export", name: logName);
        return 'No subscriptions to export';
      }

      final opmlContent = generateOpml(writable);
      final saved = await FilePicker.saveFile(
        dialogTitle: 'Save OPML file',
        fileName: 'poddr_export.opml',
        bytes: utf8.encode(opmlContent),
        mimeType: 'application/xml',
        type: FileType.custom,
        allowedExtensions: ['opml'],
      );

      if (saved == null) {
        debug("OPML export cancelled by user", name: logName);
        return null;
      }
      info("Exported ${writable.length} feeds", name: logName);
      return 'Exported ${writable.length} feeds';
    } catch (e) {
      error('OPML export failed', name: logName);
      debug('OPML export detail: $e', name: logName);
      return 'Export failed';
    }
  }
}
