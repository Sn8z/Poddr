import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:xml/xml.dart';

class OpmlProvider extends ChangeNotifier {
  final String logName = "OpmlProvider";

  SubscriptionProvider? _subscriptionProvider;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void update(SubscriptionProvider? subscriptionProvider) {
    _subscriptionProvider = subscriptionProvider;
  }

  void _setStatus(String? message) {
    _statusMessage = message;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> importOpml() async {
    if (_subscriptionProvider == null) return;

    try {
      _setLoading(true);
      _setStatus("Selecting file...");

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['opml', 'xml'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        _setStatus(null);
        _setLoading(false);
        return;
      }

      final file = result.files.first;
      final content = file.bytes;
      if (content == null) {
        _setStatus("Could not read file");
        _setLoading(false);
        return;
      }

      _setStatus("Parsing OPML...");

      final xmlString = String.fromCharCodes(content);
      final rssUrls = _parseOpml(xmlString);

      if (rssUrls.isEmpty) {
        _setStatus("No feeds found in OPML");
        _setLoading(false);
        return;
      }

      final existingRss =
          _subscriptionProvider!.subscriptions.map((p) => p.rss).toSet();
      final newRssUrls =
          rssUrls.where((rss) => !existingRss.contains(rss)).toList();

      if (newRssUrls.isEmpty) {
        _setStatus("All feeds already subscribed");
        _setLoading(false);
        return;
      }

      _setStatus("Importing ${newRssUrls.length} feeds...");

      int successCount = 0;
      for (final rss in newRssUrls) {
        final success =
            await _subscriptionProvider!.addSubscriptionSilent(rss: rss);
        if (success) successCount++;
      }

      await _subscriptionProvider!.refresh();

      final failedCount = newRssUrls.length - successCount;
      final skippedCount = rssUrls.length - newRssUrls.length;

      if (failedCount > 0 && skippedCount > 0) {
        _setStatus(
            "Imported $successCount feeds ($failedCount failed, $skippedCount already subscribed)");
      } else if (failedCount > 0) {
        _setStatus(
            "Imported $successCount of ${newRssUrls.length} feeds ($failedCount failed)");
      } else if (skippedCount > 0) {
        _setStatus(
            "Imported $successCount feeds ($skippedCount already subscribed)");
      } else {
        _setStatus("Imported $successCount feeds");
      }
    } catch (e, stackTrace) {
      log("Import error: $e", name: logName, error: e, stackTrace: stackTrace);
      _setStatus("Import failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> exportOpml() async {
    if (_subscriptionProvider == null) return;

    final subscriptions = _subscriptionProvider!.subscriptions;

    try {
      _setLoading(true);
      _setStatus("Generating OPML...");

      if (subscriptions.isEmpty) {
        _setStatus("No subscriptions to export");
        _setLoading(false);
        return;
      }

      final opmlContent = _generateOpml(subscriptions);

      _setStatus("Selecting save location...");

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
          _setStatus("Exported ${subscriptions.length} feeds");
        } else {
          _setStatus(null);
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
          _setStatus("Exported ${subscriptions.length} feeds");
        } else {
          _setStatus(null);
        }
      }
    } catch (e, stackTrace) {
      log("Export error: $e", name: logName, error: e, stackTrace: stackTrace);
      _setStatus("Export failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  String _generateOpml(List<Podcast> subscriptions) {
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
              builder.attribute('description', podcast.description);
            }
            if (podcast.image != null) {
              builder.attribute('htmlUrl', podcast.image);
            }
          });
        }
      });
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }

  List<String> _parseOpml(String xmlString) {
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
        } else if (url != null && url.contains('rss') ||
            url != null && url.contains('feed')) {
          urls.add(url);
        }
      }
    } catch (e) {
      log("OPML parse error: $e", name: logName);
    }

    return urls.toSet().toList();
  }
}
