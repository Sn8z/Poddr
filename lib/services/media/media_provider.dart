import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/core/log.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/progress.dart';
import 'package:poddr/services/history.dart';
import 'package:poddr/services/media/media_handler.dart';
import 'package:poddr/services/offline.dart';
import 'package:poddr/services/sync.dart';
import 'package:poddr/data/media/media_repository.dart';

class MediaProvider extends ChangeNotifier {
  static const String logName = "MediaProvider";

  late final PoddrMediaHandler _mediaHandler;

  final HistoryProvider _historyProvider;
  final OfflineProvider _offlineProvider;
  final SyncProvider _syncProvider;

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

  String? _lastError;
  String? get lastError => _lastError;

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

  MediaProvider({
    required HistoryProvider historyProvider,
    required OfflineProvider offlineProvider,
    required SyncProvider syncProvider,
    required IMediaRepository mediaRepository,
  })  : _historyProvider = historyProvider,
        _offlineProvider = offlineProvider,
        _syncProvider = syncProvider {
    _mediaHandler = PoddrMediaHandler(
      resolver: _resolveQueueItem,
      mediaRepository: mediaRepository,
    );
    _initMediaListeners();
  }

  Future<({String? audioSource, String? videoSource, Duration startPosition})?>
      _resolveQueueItem(String audioUrl) async {
    Duration startPosition = Duration.zero;
    try {
      final progress = await _historyProvider.getProgress(audioUrl);
      if (progress != null && !progress.isFinished) {
        startPosition = Duration(seconds: progress.position);
      }
    } catch (e) {
      warning(
        'Failed to read saved progress for queue playback, '
        'starting from the beginning: $e',
        name: logName,
      );
    }

    String? audioSource;
    String? videoSource;
    try {
      audioSource = await _offlineProvider.getLocalPath(audioUrl);
      videoSource = await _offlineProvider.getVideoLocalPath(audioUrl);
    } catch (e) {
      warning(
        'Failed to resolve a downloaded copy for queue playback, '
        'using the stream URL: $e',
        name: logName,
      );
    }

    return (
      audioSource: audioSource,
      videoSource: videoSource,
      startPosition: startPosition,
    );
  }

  void _initMediaListeners() async {
    _mediaItemSub = _mediaHandler.mediaItem.listen((mediaItem) {
      if (mediaItem == null) return;

      if (mediaItem.id != _audioUrl && _audioUrl.isNotEmpty) {
        _saveAllProgress(episodeUrl: _audioUrl, position: _position);
      }

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

  Future<void> play() async => await _mediaHandler.play();

  Future<void> pause() async => await _mediaHandler.pause();

  Future<void> playOrPause() async => await _mediaHandler.playOrPause();

  Future<void> stop() async => await _mediaHandler.stop();

  Future<void> seek(Duration position) async =>
      await _mediaHandler.seek(position);

  Future<void> setVolume(double volume) async =>
      await _mediaHandler.setVolume(volume);

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

  Future<void> setSpeed(double speed) async =>
      await _mediaHandler.setSpeed(speed);

  Future<void> skipToNext() async => await _mediaHandler.skipToNext();

  Future<void> skipToPrevious() async => await _mediaHandler.skipToPrevious();

  Future<void> skipToQueueItem(int index) async =>
      await _mediaHandler.skipToQueueItem(index);

  Future<void> removeQueueItem(int index) async =>
      await _mediaHandler.removeQueueItemAt(index);

  Future<void> clearQueue() async => await _mediaHandler.clearQueue();

  Future<bool> addToQueue({
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

    if (audioUrl == null) {
      _lastError = 'This episode cannot be added to the queue.';
      return false;
    }

    try {
      final media = MediaItem(
        id: audioUrl,
        title: episodeTitle ?? "Missing title",
        album: album ?? "Missing album",
        displayDescription: description ?? "Missing description",
        artist: artist ?? podcastTitle,
        artUri: Uri.parse(artUri ?? ""),
        extras: {
          "podcastRSS": podcastRSS,
          "videoUrl": videoUrl,
          "audioUrl": audioUrl,
          "description": description
        },
      );

      await _mediaHandler.addQueueItem(media);
      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      error('Failed to add episode to queue',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e is PoddrException
          ? e.userMessage
          : 'This episode could not be added to the queue. Please try again.';
      return false;
    }
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

  Future<bool> loadMedia({
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
    if (audioUrl == null) {
      _lastError = 'This episode cannot be played.';
      return false;
    }

    Duration startPosition = Duration.zero;
    EpisodeProgress? progress;
    try {
      progress = await _historyProvider.getProgress(audioUrl);
      if (progress != null && !progress.isFinished) {
        startPosition = Duration(seconds: progress.position);
      }
    } catch (e) {
      warning(
        'Failed to read saved progress for $audioUrl, '
        'starting from the beginning: $e',
        name: logName,
      );
    }

    String playAudioSource = audioUrl;
    String? playVideoSource = videoUrl;

    try {
      final localPath = await _offlineProvider.getLocalPath(audioUrl);
      if (localPath != null) {
        playAudioSource = localPath;
        info("Playing audio from local file: $localPath", name: logName);
      }

      if (videoUrl != null) {
        final localVideoPath =
            await _offlineProvider.getVideoLocalPath(audioUrl);
        if (localVideoPath != null) {
          playVideoSource = localVideoPath;
          info("Playing video from local file: $localVideoPath", name: logName);
        }
      }
    } catch (e) {
      warning(
        'Failed to resolve a downloaded copy for $audioUrl, '
        'using the stream URL: $e',
        name: logName,
      );
    }

    try {
      await _mediaHandler.loadMedia(
        audioUrl: audioUrl,
        videoUrl: videoUrl,
        audioSource: playAudioSource,
        videoSource: playVideoSource,
        podcastTitle: podcastTitle,
        podcastRSS: podcastRSS,
        episodeTitle: episodeTitle,
        album: album,
        description: description,
        artist: artist,
        artUri: artUri,
        startPosition: startPosition,
      );
      _lastError = null;
      await _historyProvider.upsertProgress(
        audioUrl,
        position: startPosition.inSeconds,
        duration: _duration.inSeconds,
        markFinished: false,
        title: episodeTitle ?? "Missing title",
        description: description ?? "Missing description",
        imageUrl: artUri ?? "",
        podcastTitle: podcastTitle ?? "",
        podcastRSS: podcastRSS ?? "",
        videoUrl: videoUrl,
      );
      return true;
    } catch (e, stackTrace) {
      error('Failed to load media',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e is PoddrException
          ? e.userMessage
          : 'This episode could not be played. Please try again.';
      return false;
    }
  }

  Future<void> _saveLocalProgress({
    String? episodeUrl,
    Duration? position,
  }) async {
    final String url = episodeUrl ?? _audioUrl;
    final Duration pos = position ?? _position;
    final int dur = _duration.inSeconds;

    if (dur <= 0 || pos.inSeconds >= dur) return;

    await _historyProvider.upsertProgress(
      url,
      position: pos.inSeconds,
      duration: dur,
    );
  }

  Future<void> _recordSyncAction({
    String? episodeUrl,
    Duration? position,
  }) async {
    final String url = episodeUrl ?? _audioUrl;
    final Duration pos = position ?? _position;
    final int dur = _duration.inSeconds;

    if (dur <= 0 || pos.inSeconds >= dur) return;

    _syncProvider.recordEpisodeAction(
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
