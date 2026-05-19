import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:poddr/core/log.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/services/history.dart';
import 'package:poddr/services/media/media_handler.dart';
import 'package:poddr/services/offline.dart';
import 'package:poddr/services/sync.dart';

class MediaProvider extends ChangeNotifier {
  static const String logName = "MediaProvider";

  final PoddrMediaHandler _mediaHandler = PoddrMediaHandler();

  HistoryProvider? _historyProvider;
  OfflineProvider? _offlineProvider;
  SyncProvider? _syncProvider;

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

  String? _videoUrl;
  String? get videoUrl => _videoUrl;
  bool get hasVideo => _videoUrl != null && _videoUrl!.isNotEmpty;
  VideoController? get videoController => _mediaHandler.videoController;

  double _volume = 56.0;
  double get volume => _volume;

  double? _previousVolume;

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

  String _lastAudioUrl = "";
  DateTime? _lastProgressSave;

  List<PodcastEpisode> get mediaQueue => _mediaHandler.mediaQueue;
  bool get canGoNext =>
      _mediaHandler.currentIndex < _mediaHandler.mediaQueue.length - 1;
  bool get canGoPrevious => _mediaHandler.currentIndex > 0;

  late final StreamSubscription<MediaItem?> _mediaItemSub;
  late final StreamSubscription<AudioEvent> _eventsSub;
  late final StreamSubscription<PlaybackState> _playbackStateSub;
  late final StreamSubscription<double> _volumeSub;
  late final StreamSubscription<List<MediaItem>> _queueSub;

  MediaProvider() {
    _initMediaListeners();
  }

  void update(HistoryProvider? historyProvider,
      OfflineProvider? offlineProvider, SyncProvider? syncProvider) {
    _historyProvider = historyProvider;
    _offlineProvider = offlineProvider;
    _syncProvider = syncProvider;
  }

  void _initMediaListeners() async {
    _mediaItemSub = _mediaHandler.mediaItem.listen((mediaItem) {
      if (mediaItem == null) return;

      _lastAudioUrl = mediaItem.id;
      _audioUrl = mediaItem.id;
      _episodeTitle = mediaItem.title;
      _podcastTitle = mediaItem.artist ?? mediaItem.album ?? "";
      _podcastRSS = mediaItem.extras?["podcastRSS"] ?? "";
      _duration = mediaItem.duration ?? Duration.zero;
      _artwork = mediaItem.artUri?.toString() ?? "";
      _videoUrl = mediaItem.extras?['videoUrl'] as String?;

      notifyListeners();
    });

    _eventsSub = _mediaHandler.events.listen((event) {
      switch (event) {
        case AudioEvent.pause:
        case AudioEvent.stop:
          _saveAllProgress();
          break;
        case AudioEvent.seek:
          _saveAllProgress();
          break;
        case AudioEvent.mediaItemChanged:
          _saveAllProgress(
            episodeUrl: _lastAudioUrl,
            position: _position,
          );
          break;
        case AudioEvent.play:
          break;
      }
    });

    _playbackStateSub = _mediaHandler.playbackState.listen((state) {
      _isPlaying = state.playing;
      _position = state.updatePosition;
      _bufferedPosition = state.bufferedPosition;
      _isLoading = state.processingState == AudioProcessingState.loading ||
          state.processingState == AudioProcessingState.buffering;
      notifyListeners();

      final now = DateTime.now();
      if (_isPlaying &&
          (_lastProgressSave == null ||
              now.difference(_lastProgressSave!) >=
                  const Duration(seconds: 30))) {
        _saveAllProgress();
        _lastProgressSave = now;
      }
    });

    _volumeSub = _mediaHandler.volume.listen((volume) {
      _volume = volume;
      notifyListeners();
    });

    _queueSub = _mediaHandler.queue.listen((queue) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _mediaItemSub.cancel();
    _eventsSub.cancel();
    _playbackStateSub.cancel();
    _volumeSub.cancel();
    _queueSub.cancel();
    super.dispose();
  }

  void play() async => await _mediaHandler.play();

  void pause() async => await _mediaHandler.pause();

  void playOrPause() async => await _mediaHandler.playOrPause();

  void stop() async => await _mediaHandler.stop();

  void seek(Duration position) async => await _mediaHandler.seek(position);

  void setVolume(double volume) async => await _mediaHandler.setVolume(volume);

  void toggleMute() {
    if (_volume > 0) {
      _previousVolume = _volume;
      setVolume(0);
    } else {
      setVolume(_previousVolume ?? 100.0);
    }
  }

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
    String? videoUrl,
    String? podcastTitle,
    String? podcastRSS,
    String? episodeTitle,
    String? album,
    String? description,
    String? artist,
    String? artUri,
  }) async {
    debug("Adding to queue", name: logName);

    if (audioUrl == null) return;

    final media = MediaItem(
      id: audioUrl,
      title: episodeTitle ?? "Missing title",
      album: album ?? "Missing album",
      displayDescription: description ?? "Missing description",
      artist: artist ?? podcastTitle,
      artUri: Uri.parse(artUri ?? ""),
      extras: {"podcastRSS": podcastRSS, "videoUrl": videoUrl},
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
    String? videoUrl,
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
    String? playVideoUrl = videoUrl;

    if (_offlineProvider != null) {
      final localPath = await _offlineProvider!.getLocalPath(audioUrl);
      if (localPath != null) {
        playUrl = localPath;
        info("Playing audio from local file: $localPath", name: logName);
      }

      if (videoUrl != null) {
        final localVideoPath =
            await _offlineProvider!.getVideoLocalPath(audioUrl);
        if (localVideoPath != null) {
          playVideoUrl = localVideoPath;
          info("Playing video from local file: $localVideoPath", name: logName);
        }
      }
    }

    await _mediaHandler.loadMedia(
      audioUrl: playUrl,
      videoUrl: playVideoUrl,
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
        _duration.inSeconds,
        playVideoUrl,
      );
    }
  }

  Future<void> _saveLocalProgress({
    String? episodeUrl,
    Duration? position,
  }) async {
    if (_historyProvider == null) return;

    final String url = episodeUrl ?? _audioUrl;
    final Duration pos = position ?? _position;
    final int dur = _duration.inSeconds;

    if (dur <= 0 || pos.inSeconds >= dur) return;

    await _historyProvider!.updateProgress(url, pos.inSeconds, dur);
  }

  Future<void> _recordSyncAction({
    String? episodeUrl,
    Duration? position,
  }) async {
    if (_syncProvider == null) return;

    final String url = episodeUrl ?? _audioUrl;
    final Duration pos = position ?? _position;
    final int dur = _duration.inSeconds;

    if (dur <= 0 || pos.inSeconds >= dur) return;

    _syncProvider?.recordEpisodeAction(
      podcastRss: podcastRSS,
      episodeUrl: url,
      action: 'play',
      position: pos.inSeconds,
    );
  }

  Future<void> _saveAllProgress({
    String? episodeUrl,
    Duration? position,
  }) async {
    await _saveLocalProgress(episodeUrl: episodeUrl, position: position);
    await _recordSyncAction(episodeUrl: episodeUrl, position: position);
  }
}
