import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/offline/drift_offline_repository.dart';
import 'package:poddr/data/offline/offline_repository.dart';
import 'package:poddr/models/episode.dart';

class OfflineProvider extends ChangeNotifier {
  final String logName = "OfflineProvider";

  final IOfflineRepository _repository;

  List<OfflineEpisode> _downloads = [];
  List<OfflineEpisode> get downloads => _downloads;

  final Map<String, double> _downloadProgress = {};
  Map<String, double> get downloadProgress => _downloadProgress;

  final Set<String> _downloading = {};
  Set<String> get downloading => _downloading;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  OfflineProvider({IOfflineRepository? repository})
      : _repository = repository ?? DriftOfflineRepository() {
    _init();
  }

  Future<void> _init() async {
    await getDownloads();
  }

  Future<String> get _downloadDir async {
    final appDir = await getApplicationSupportDirectory();
    final downloadDir = Directory('${appDir.path}/downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir.path;
  }

  String _getFileName(String audioUrl) {
    final cleanUrl = audioUrl.split('?').first;
    final extension = cleanUrl.split('.').lastOrNull ?? 'mp3';
    return '${audioUrl.hashCode}.$extension';
  }

  Future<void> getDownloads() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _downloads = await _repository.getAll();
    } catch (e, stackTrace) {
      log(
        'Failed to get downloads',
        name: logName,
        error: e,
        stackTrace: stackTrace,
      );
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isDownloaded(String audioUrl) async {
    final episode = await _repository.getByAudioUrl(audioUrl);
    return episode != null;
  }

  Future<String?> getLocalPath(String audioUrl) async {
    final episode = await _repository.getByAudioUrl(audioUrl);
    if (episode == null) return null;

    final file = File(episode.localPath);
    if (await file.exists()) {
      return episode.localPath;
    }
    return null;
  }

  Future<void> download(PodcastEpisode episode) async {
    if (_downloading.contains(episode.audioUrl)) return;

    final existing = await _repository.getByAudioUrl(episode.audioUrl);
    if (existing != null) {
      final localFile = File(existing.localPath);
      if (await localFile.exists()) {
        return;
      }
      await _repository.remove(episode.audioUrl);
    }

    _downloading.add(episode.audioUrl);
    _downloadProgress[episode.audioUrl] = 0.0;
    notifyListeners();

    try {
      final downloadDir = await _downloadDir;
      final fileName = _getFileName(episode.audioUrl);
      final localPath = '$downloadDir/$fileName';
      final file = File(localPath);

      final response = await http.Client().send(
        http.Request('GET', Uri.parse(episode.audioUrl)),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to download: ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      int downloadedBytes = 0;

      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;

        if (contentLength > 0) {
          _downloadProgress[episode.audioUrl] = downloadedBytes / contentLength;
          notifyListeners();
        }
      }

      await sink.flush();
      await sink.close();

      await _repository.add(
        OfflineEpisodesCompanion.insert(
          audioUrl: episode.audioUrl,
          localPath: localPath,
          title: episode.title,
          description: episode.description,
          imageUrl: episode.imageUrl ?? '',
          podcastTitle: episode.podcastTitle ?? '',
          podcastRSS: episode.podcastRSS ?? '',
          duration: episode.duration?.inSeconds ?? 0,
          fileSize: downloadedBytes,
        ),
      );

      await getDownloads();
    } catch (e, stackTrace) {
      log(
        'Failed to download episode',
        name: logName,
        error: e,
        stackTrace: stackTrace,
      );
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _downloading.remove(episode.audioUrl);
      _downloadProgress.remove(episode.audioUrl);
      notifyListeners();
    }
  }

  Future<void> remove(String audioUrl) async {
    try {
      final episode = await _repository.getByAudioUrl(audioUrl);
      if (episode != null) {
        final file = File(episode.localPath);
        if (await file.exists()) {
          await file.delete();
        }
        await _repository.remove(audioUrl);
        await getDownloads();
      }
    } catch (e, stackTrace) {
      log(
        'Failed to remove download',
        name: logName,
        error: e,
        stackTrace: stackTrace,
      );
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelDownload(String audioUrl) async {
    if (!_downloading.contains(audioUrl)) return;

    _downloading.remove(audioUrl);
    _downloadProgress.remove(audioUrl);
    notifyListeners();

    try {
      final episode = await _repository.getByAudioUrl(audioUrl);
      if (episode != null) {
        final file = File(episode.localPath);
        if (await file.exists()) {
          await file.delete();
        }
        await _repository.remove(audioUrl);
      }
    } catch (e) {
      log(
        'Failed to clean up cancelled download',
        name: logName,
        error: e,
      );
    }
  }

  Future<int> getTotalDownloadSize() async {
    int totalSize = 0;
    for (final download in _downloads) {
      totalSize += download.fileSize;
    }
    return totalSize;
  }

  PodcastEpisode? toPodcastEpisode(OfflineEpisode data) {
    return PodcastEpisode(
      title: data.title,
      description: data.description,
      audioUrl: data.audioUrl,
      imageUrl: data.imageUrl,
      podcastTitle: data.podcastTitle,
      podcastRSS: data.podcastRSS,
      duration: Duration(seconds: data.duration),
      publicationDate: data.downloadedAt,
    );
  }
}
