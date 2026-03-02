import 'dart:async';
import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/services/history.dart';
import 'package:poddr/services/media/media_handler.dart';
import 'package:poddr/services/offline.dart';

class MediaProvider extends ChangeNotifier {
  final String logName = "MediaProvider";

  final PoddrMediaHandler _mediaHandler = PoddrMediaHandler();

  HistoryProvider? _historyProvider;
  OfflineProvider? _offlineProvider;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  String _episodeTitle = "";
  String get episodeTitle => _episodeTitle;

  String _podcastTitle = "";
  String get podcastTitle => _podcastTitle;

  String _artwork = "";
  String get artwork => _artwork;

  String _podcastRSS = "";
  String get podcastRSS => _podcastRSS;

  String _audioUrl = "";
  String get audioUrl => _audioUrl;

  double _volume = 56.0;
  double get volume => _volume;

  double get speed => _mediaHandler.playbackState.value.speed;

  Duration _position = Duration.zero;
  Duration get position => _position;

  Duration _bufferedPosition = Duration.zero;
  Duration get bufferedPosition => _bufferedPosition;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  AudioServiceRepeatMode get repeatMode => _mediaHandler.repeatMode;
  bool get isShuffling => _mediaHandler.isShuffling;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PodcastEpisode> get mediaQueue => _mediaHandler.mediaQueue;
  bool get canGoNext =>
      _mediaHandler.currentIndex < _mediaHandler.mediaQueue.length - 1;
  bool get canGoPrevious => _mediaHandler.currentIndex > 0;

  MediaProvider() {
    _initMediaListeners();
  }

  void update(
      HistoryProvider? historyProvider, OfflineProvider? offlineProvider) {
    _historyProvider = historyProvider;
    _offlineProvider = offlineProvider;
  }

  void _initMediaListeners() async {
    _mediaHandler.mediaItem.listen((mediaItem) {
      if (mediaItem == null) return;
      _audioUrl = mediaItem.id;
      _episodeTitle = mediaItem.title;
      _podcastTitle = mediaItem.artist ?? mediaItem.album ?? "";
      _podcastRSS = mediaItem.extras?["podcastRSS"] ?? "";
      _duration = mediaItem.duration ?? Duration.zero;
      _artwork = mediaItem.artUri?.toString() ?? "";

      notifyListeners();
    });

    _mediaHandler.playbackState.listen((state) {
      _isPlaying = state.playing;
      _position = state.updatePosition;
      _bufferedPosition = state.bufferedPosition;
      _isLoading = state.processingState == AudioProcessingState.loading ||
          state.processingState == AudioProcessingState.buffering;
      notifyListeners();

      if (_position.inSeconds % 10 == 0) {
        _saveProgress();
      }
    });

    _mediaHandler.volume.listen((volume) {
      _volume = volume;
      notifyListeners();
    });

    _mediaHandler.queue.listen((queue) {
      notifyListeners();
    });
  }

  void play() async => await _mediaHandler.play();

  void pause() async => await _mediaHandler.pause();

  void playOrPause() async => await _mediaHandler.playOrPause();

  void stop() async => await _mediaHandler.stop();

  void seek(Duration position) async => await _mediaHandler.seek(position);

  void setVolume(double volume) async => await _mediaHandler.setVolume(volume);

  void increaseVolume([double amount = 5]) {
    final newVolume = (_volume + amount);
    setVolume(newVolume);
  }

  void decreaseVolume([double amount = 5]) {
    final newVolume = (_volume - amount);
    setVolume(newVolume);
  }

  void setSpeed(double speed) async => await _mediaHandler.setSpeed(speed);

  void skipToNext() async => await _mediaHandler.skipToNext();

  void skipToPrevious() async => await _mediaHandler.skipToPrevious();

  void skipToQueueItem(int index) async =>
      await _mediaHandler.skipToQueueItem(index);

  void removeQueueItem(int index) async =>
      await _mediaHandler.removeQueueItemAt(index);

  void clearQueue() async => await _mediaHandler.clearQueue();

  void addToQueue({
    String? audioUrl,
    String? podcastTitle,
    String? podcastRSS,
    String? episodeTitle,
    String? album,
    String? description,
    String? artist,
    String? artUri,
  }) async {
    log("Adding to queue", name: logName);
    log("AudioUrl: $audioUrl", name: logName);
    log("PodcastTitle: $podcastTitle", name: logName);
    log("PodcastRSS: $podcastRSS", name: logName);
    log("EpisodeTitle: $episodeTitle", name: logName);
    log("Album: $album", name: logName);
    log("Description: $description", name: logName);
    log("Artist: $artist", name: logName);
    log("ArtUri: $artUri", name: logName);

    if (audioUrl == null) return;

    final media = MediaItem(
      id: audioUrl,
      title: episodeTitle ?? "Missing title",
      album: album ?? "Missing album",
      displayDescription: description ?? "Missing description",
      artist: artist ?? podcastTitle,
      artUri: Uri.parse(artUri ?? ""),
      extras: {"podcastRSS": podcastRSS},
    );

    await _mediaHandler.addQueueItem(media);
  }

  Future<void> cycleRepeatMode() async {
    switch (_mediaHandler.repeatMode) {
      case AudioServiceRepeatMode.none:
        await _mediaHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case AudioServiceRepeatMode.one:
        await _mediaHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
      case AudioServiceRepeatMode.all:
        await _mediaHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      default:
        await _mediaHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
    }
  }

  Future<void> cycleShuffleMode() async {
    if (_mediaHandler.isShuffling) {
      await _mediaHandler.setShuffleMode(AudioServiceShuffleMode.none);
    } else {
      await _mediaHandler.setShuffleMode(AudioServiceShuffleMode.all);
    }
  }

  Future<void> loadMedia({
    String? audioUrl,
    String? episodeTitle,
    String? podcastTitle,
    String? podcastRSS,
    String? artUri,
    String? artist,
    String? album,
    String? description,
  }) async {
    if (audioUrl == null) return;
    if (_historyProvider == null) return;

    Duration startPosition = Duration.zero;
    final progress = await _historyProvider!.getProgress(audioUrl);
    if (progress != null && !progress["isFinished"]) {
      startPosition = Duration(seconds: progress["position"]);
    }

    String playUrl = audioUrl;
    if (_offlineProvider != null) {
      final localPath = await _offlineProvider!.getLocalPath(audioUrl);
      if (localPath != null) {
        playUrl = localPath;
        log("Playing from local file: $localPath", name: logName);
      }
    }

    await _mediaHandler.loadMedia(
      audioUrl: playUrl,
      podcastTitle: podcastTitle,
      podcastRSS: podcastRSS,
      episodeTitle: episodeTitle,
      album: album,
      description: description,
      artist: artist,
      artUri: artUri,
      startPosition: startPosition,
    );

    if (progress == null) {
      _historyProvider!.addToHistory(
        audioUrl,
        episodeTitle ?? "Missing title",
        description ?? "Missing description",
        artUri ?? "",
        podcastTitle ?? "",
        podcastRSS ?? "",
        _position.inSeconds,
        _duration.inSeconds,
      );
    }
  }

  Future<void> _saveProgress() async {
    if (_historyProvider == null) return;

    final int pos = _position.inSeconds;
    final int dur = _duration.inSeconds;

    if (dur > 0 && pos < dur) {
      await _historyProvider!.updateProgress(_audioUrl, pos, dur);
    }
  }
}
