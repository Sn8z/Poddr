import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'dart:math' hide log;
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart' hide AudioDevice;
import 'package:flutter/foundation.dart';
import 'package:poddr/data/media/media_repository.dart';
import 'package:poddr/data/media/prefs_media_repository.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/services/history.dart';
import 'package:poddr/services/media/media_player.dart';

class MediaProvider extends BaseAudioHandler
    with QueueHandler, SeekHandler, ChangeNotifier {
  final PoddrMediaPlayer _player = PoddrMediaPlayer();

  //TODO: Improve check... Platform causes issues on web
  final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  final String logName = "MediaProvider";

  final IMediaRepository _mediaRepository;
  HistoryProvider? _historyProvider;

  AudioHandler? _audioHandler;

  bool get isPlaying => _player.isPlaying;

  double _volume = 0.0;
  double get volume => _volume;

  Duration _position = Duration.zero;
  Duration get position => _position;

  Duration _bufferedPosition = Duration.zero;
  Duration get bufferedPosition => _bufferedPosition;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<MediaItem> _mediaQueue = [];
  List<PodcastEpisode> get mediaQueue => _mediaQueue
      .map((item) => PodcastEpisode.fromMediaItem(mediaItem: item))
      .toList();

  int _currentIndex = -1;
  int get currentIndex => _currentIndex;

  bool get canGoNext => _currentIndex < _mediaQueue.length - 1;
  bool get canGoPrevious => _currentIndex > 0;

  bool _isShuffling = false;
  bool get isShuffling => _isShuffling;

  AudioServiceRepeatMode _repeatMode = AudioServiceRepeatMode.none;
  AudioServiceRepeatMode get repeatMode => _repeatMode;

  MediaProvider({IMediaRepository? mediaRepository})
      : _mediaRepository = mediaRepository ?? SharedPrefsMediaRepository() {
    _initAudioService();
    _initPlayer();
    _initStreams();
  }

  void update(HistoryProvider? historyProvider) {
    _historyProvider = historyProvider;
  }

  Future<void> _initAudioService() async {
    final AudioSession audioSession = await AudioSession.instance;
    await audioSession.configure(const AudioSessionConfiguration.speech());
    audioSession.setActive(true);

    audioSession.becomingNoisyEventStream.listen((_) {
      log("Headphones disconnected", name: logName);
      _player.pause();
    });

    audioSession.devicesChangedEventStream.listen((event) {
      log('Devices added: ${event.devicesAdded}', name: logName);
      log('Devices removed: ${event.devicesRemoved}', name: logName);
    });

    _audioHandler ??= await AudioService.init(
      builder: () => this,
      config: const AudioServiceConfig(
        androidNotificationChannelName: "Poddr",
        androidNotificationChannelId: "com.sn8z.poddr",
        androidNotificationChannelDescription: "Poddr media controls",
        androidStopForegroundOnPause: false,
        androidNotificationOngoing: false,
      ),
    );
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setRate(_mediaRepository.getRate());
      if (isMobile) {
        await _player.setVolume(100);
      } else {
        await _player.setVolume(_mediaRepository.getVolume());
      }

      loadMedia(
        audioUrl: _mediaRepository.getId(),
        episodeTitle: _mediaRepository.getEpisodeTitle(),
        podcastTitle: _mediaRepository.getPodcastTitle(),
        podcastRSS: _mediaRepository.getRSS(),
        artUri: _mediaRepository.getArtwork(),
        autoplay: false,
      );
    } catch (error, stackTrace) {
      log(
        error.toString(),
        time: DateTime.now(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _initStreams() async {
    mediaItem.listen(_handleMediaItemChange);

    final player = _player.player;
    player.stream.playing.listen(_handlePlayingState);
    player.stream.completed.listen(_handleCompletion);
    player.stream.position.listen(_handlePositionChange);
    player.stream.duration.listen(_handleDurationChange);
    player.stream.buffer.listen(_handleBufferChange);
    player.stream.rate.listen(_handleRateChange);
    player.stream.buffering.listen(_handleBufferingState);
    player.stream.error.listen(_handleError);

    if (!isMobile) {
      player.stream.volume.listen(_handleVolumeChange);
    }
  }

  void _handleMediaItemChange(MediaItem? media) {
    if (media == null) return;
    _mediaRepository.setId(media.id);
    _mediaRepository.setEpisodeTitle(media.title);
    _mediaRepository.setPodcastTitle(media.artist ?? "");
    _mediaRepository.setRSS(media.extras?["podcastRSS"] ?? "");
    _mediaRepository.setArtwork(media.artUri.toString());
  }

  void _handlePlayingState(bool value) {
    log(value ? "Playing" : "Paused", name: logName);
    playbackState.add(playbackState.value.copyWith(
      playing: value,
      controls: [
        MediaControl.skipToPrevious,
        value ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekBackward,
        MediaAction.seekForward,
        MediaAction.setShuffleMode,
        MediaAction.setRepeatMode,
      },
    ));
    notifyListeners();

    if (!value) {
      saveProgress();
    }
  }

  void _handleCompletion(bool isCompleted) {
    log("Completed: $isCompleted", name: logName);

    if (isCompleted) {
      switch (_repeatMode) {
        case AudioServiceRepeatMode.one:
          log("Repeat one: restarting current track", name: logName);
          seek(Duration.zero);
          play();
          break;

        case AudioServiceRepeatMode.all:
          if (_mediaQueue.isNotEmpty) {
            if (_currentIndex >= _mediaQueue.length - 1) {
              log("Repeat all: restarting queue from beginning", name: logName);
              skipToQueueItem(0);
            } else {
              log("Repeat all: playing next track", name: logName);
              skipToNext();
            }
          }
          break;

        default:
          if (_currentIndex < _mediaQueue.length - 1) {
            log("No repeat: playing next track", name: logName);
            skipToNext();
          } else {
            log("No repeat: queue completed, stopping", name: logName);
            pause();
          }
          break;
      }
    }

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.completed,
    ));
    _isLoading = false;
    notifyListeners();

    saveProgress();
  }

  void _handlePositionChange(Duration value) {
    //log("Position: $value", name: logName);
    playbackState.add(playbackState.value.copyWith(
      updatePosition: value,
    ));
    _position = value;
    notifyListeners();

    if (value.inSeconds % 10 == 0 && value.inSeconds > 0) saveProgress();
  }

  void _handleDurationChange(Duration value) {
    log("Duration: $value", name: logName);
    mediaItem.add(mediaItem.value?.copyWith(duration: value));
    _duration = value;
    notifyListeners();
  }

  void _handleRateChange(double value) {
    log("Playback rate: $value", name: logName);
    playbackState.add(playbackState.value.copyWith(
      speed: value,
    ));
    _mediaRepository.setRate(value);
    notifyListeners();
  }

  void _handleBufferChange(Duration value) {
    //log("Buffer: $value", name: logName);
    playbackState.add(playbackState.value.copyWith(
      bufferedPosition: value,
    ));
    _bufferedPosition = value;
    notifyListeners();
  }

  void _handleBufferingState(bool value) {
    log(value ? "Buffering" : "Done buffering", name: logName);
    playbackState.add(playbackState.value.copyWith(
      processingState:
          value ? AudioProcessingState.buffering : AudioProcessingState.ready,
    ));
    _isLoading = value;
    notifyListeners();
  }

  void _handleVolumeChange(double value) {
    log("Volume: $value", name: logName);
    _mediaRepository.setVolume(value);
    _volume = value;
    notifyListeners();
  }

  void _handleError(String error) {
    log(
      error,
      name: logName,
      error: error,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMedia({
    String? audioUrl,
    String? podcastTitle,
    String? podcastRSS,
    String? episodeTitle,
    String? album,
    String? description,
    String? artist,
    String? artUri,
    Duration startPosition = Duration.zero,
    bool autoplay = true,
  }) async {
    log("Loading media", name: logName);
    log("AudioUrl: $audioUrl", name: logName);
    log("PodcastTitle: $podcastTitle", name: logName);
    log("PodcastRSS: $podcastRSS", name: logName);
    log("EpisodeTitle: $episodeTitle", name: logName);
    log("Album: $album", name: logName);
    log("Description: $description", name: logName);
    log("Artist: $artist", name: logName);
    log("ArtUri: $artUri", name: logName);
    log("StartPosition: $startPosition", name: logName);
    log("Autoplay: $autoplay", name: logName);

    if (audioUrl == null) return;
    if (_historyProvider == null) return;

    final media = MediaItem(
      id: audioUrl,
      title: episodeTitle ?? "Missing title",
      album: album ?? "Missing album",
      displayDescription: description ?? "Missing description",
      artist: artist ?? podcastTitle,
      artUri: Uri.parse(artUri ?? ""),
      extras: {"podcastRSS": podcastRSS},
    );

    final progress = await _historyProvider!.getProgress(media.id);
    if (progress != null) {
      startPosition = Duration(seconds: progress['position']);
    }

    mediaItem.add(media);

    await _player.open(
      media.id,
      startPosition: startPosition,
      autoplay: false,
    );

    if (progress == null) {
      _historyProvider!.addToHistory(
        media.id,
        media.title,
        media.displayDescription ?? "",
        media.artUri.toString(),
        podcastTitle ?? "",
        podcastRSS ?? "",
        _position.inSeconds,
        _duration.inSeconds,
      );
    }

    if (autoplay) await _player.play();
  }

  Future<void> addToQueue({
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

    await addQueueItem(media);
  }

  Future<void> setVolume(double volume) async {
    if (!isMobile) await _player.setVolume(volume);
  }

  void saveProgress() async {
    final media = mediaItem.value;
    if (media == null) return;
    if (_historyProvider == null) return;
    await _historyProvider!.updateProgress(
      media.id,
      _position.inSeconds,
      _duration.inSeconds,
    );
    _mediaRepository.setPosition(_position);
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> playOrPause() async {
    if (_player.isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setRate(speed);
  }

  @override
  Future<void> seek(Duration position) async {
    _isLoading = true;
    notifyListeners();
    await _player.seek(position);
    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> skipToNext() async {
    log("Skipping to next", name: logName);

    final queueLength = _mediaQueue.length;
    if (_isShuffling) {
      int newIndex;
      do {
        newIndex = Random().nextInt(queueLength);
      } while (newIndex == _currentIndex);

      await skipToQueueItem(newIndex);
    } else if (_currentIndex < queueLength - 1) {
      final nextIndex = _currentIndex + 1;
      if (nextIndex > queueLength - 1) {
        await skipToQueueItem(0);
      } else {
        await skipToQueueItem(nextIndex);
      }
    } else {
      log("No next item in queue", name: logName);
      await _player.pause();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex <= 0) {
      log("No previous item in queue", name: logName);
      return;
    } else {
      log("Skipped to previous", name: logName);
      final prevIndex = _currentIndex - 1;
      await skipToQueueItem(prevIndex);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _mediaQueue.length) {
      log("Index out of bounds: $index", name: logName);
      return;
    }

    final media = _mediaQueue[index];

    await loadMedia(
      audioUrl: media.id,
      episodeTitle: media.title,
      podcastTitle: media.artist,
      album: media.album,
      description: media.displayDescription,
      artist: media.artist,
      podcastRSS: media.extras?["podcastRSS"],
      artUri: media.artUri.toString(),
      startPosition: Duration.zero,
      autoplay: true,
    );

    _currentIndex = index;

    log("Skipped to queue item $index", name: logName);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    _mediaQueue.add(mediaItem);
    queue.add(_mediaQueue);
    notifyListeners();
    log("Added to queue: ${mediaItem.id}", name: logName);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    for (var item in mediaItems) {
      _mediaQueue.add(item);
      log("Added to queue: ${item.id}", name: logName);
    }
    queue.add(_mediaQueue);
    notifyListeners();
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= _mediaQueue.length) {
      log("Index out of bounds: $index", name: logName);
      return;
    }
    _mediaQueue.removeAt(index);
    queue.add(_mediaQueue);
    notifyListeners();

    if (_currentIndex >= index) {
      _currentIndex--;
    }

    log("Removed from queue: index $index", name: logName);
  }

  Future<void> clearQueue() async {
    _mediaQueue.clear();
    queue.add(_mediaQueue);
    notifyListeners();
    log("Cleared queue", name: logName);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    log("Setting repeat mode: $repeatMode", name: logName);

    _repeatMode = repeatMode;

    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));

    notifyListeners();
  }

  Future<void> cycleRepeatMode() async {
    switch (_repeatMode) {
      case AudioServiceRepeatMode.none:
        await setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case AudioServiceRepeatMode.one:
        await setRepeatMode(AudioServiceRepeatMode.all);
        break;
      case AudioServiceRepeatMode.all:
        await setRepeatMode(AudioServiceRepeatMode.none);
        break;
      default:
        await setRepeatMode(AudioServiceRepeatMode.none);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    log("Shuffle mode: $shuffleMode", name: logName);

    _isShuffling = shuffleMode == AudioServiceShuffleMode.all;

    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));

    notifyListeners();
  }

  Future<void> cycleShuffleMode() async {
    if (_isShuffling) {
      await setShuffleMode(AudioServiceShuffleMode.none);
    } else {
      await setShuffleMode(AudioServiceShuffleMode.all);
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    super.stop();
  }

  @override
  Future<void> dispose() async {
    log("Disposing media", name: logName);
    await _player.dispose();
    super.dispose();
  }
}
