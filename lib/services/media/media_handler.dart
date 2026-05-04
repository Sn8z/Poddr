import 'dart:developer';
import 'dart:async';
import 'dart:math' hide log;
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart' hide AudioDevice;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:poddr/data/media/media_repository.dart';
import 'package:poddr/data/media/prefs_media_repository.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/services/media/media_player.dart';

enum AudioEvent { play, pause, seek, stop, mediaItemChanged }

class PoddrMediaHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final String logName = "PoddrMediaHandler";

  late final PoddrMediaPlayer _player = PoddrMediaPlayer();

  DateTime? _lastPositionSave;
  static const Duration _saveInterval = Duration(seconds: 10);

  final StreamController<AudioEvent> _eventController =
      StreamController<AudioEvent>.broadcast();
  Stream<AudioEvent> get events => _eventController.stream;

  late final StreamSubscription<MediaItem?> _mediaItemSub;
  late final StreamSubscription<bool> _playingSub;
  late final StreamSubscription<bool> _completedSub;
  late final StreamSubscription<Duration> _positionSub;
  late final StreamSubscription<Duration> _durationSub;
  late final StreamSubscription<Duration> _bufferSub;
  late final StreamSubscription<double> _rateSub;
  late final StreamSubscription<bool> _bufferingSub;
  late final StreamSubscription<double> _volumeSub;
  late final StreamSubscription<String> _errorSub;

  Stream<double> get volume => _player.player.stream.volume;

  VideoController? get videoController => _player.videoController;

  final IMediaRepository _mediaRepository;

  final List<MediaItem> _mediaQueue = [];
  List<PodcastEpisode> get mediaQueue => _mediaQueue
      .map((item) => PodcastEpisode.fromMediaItem(mediaItem: item))
      .toList();

  int _currentIndex = -1;
  int get currentIndex => _currentIndex;

  bool _isShuffling = false;
  bool get isShuffling => _isShuffling;

  AudioServiceRepeatMode _repeatMode = AudioServiceRepeatMode.none;
  AudioServiceRepeatMode get repeatMode => _repeatMode;

  PoddrMediaHandler({IMediaRepository? mediaRepository})
      : _mediaRepository = mediaRepository ?? SharedPrefsMediaRepository() {
    _initPlayer();
    _initListeners();
    _initAudioSession();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.init(
        rate: await _mediaRepository.getRate(),
        volume: await _mediaRepository.getVolume(),
      );

      final audioUrl = await _mediaRepository.getAudioUrl();
      if (audioUrl.isNotEmpty) {
        loadMedia(
          audioUrl: audioUrl,
          videoUrl: await _mediaRepository.getVideoUrl(),
          episodeTitle: await _mediaRepository.getEpisodeTitle(),
          podcastTitle: await _mediaRepository.getPodcastTitle(),
          podcastRSS: await _mediaRepository.getRSS(),
          artUri: await _mediaRepository.getArtwork(),
          startPosition: await _mediaRepository.getPosition(),
          autoplay: false,
        );
      } else {
        log("No media to load", name: logName);
      }
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

  Future<void> _initAudioSession() async {
    final AudioSession audioSession = await AudioSession.instance;
    await audioSession.configure(const AudioSessionConfiguration.music());
    audioSession.setActive(true);

    audioSession.becomingNoisyEventStream.listen((_) {
      log("Headphones disconnected", name: logName);
      _player.pause();
    });

    audioSession.devicesChangedEventStream.listen((event) {
      log('Devices added: ${event.devicesAdded}', name: logName);
      log('Devices removed: ${event.devicesRemoved}', name: logName);
    });

    await AudioService.init(
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

  void _initListeners() {
    _mediaItemSub = mediaItem.listen(_handleMediaItemChange);

    final player = _player.player;
    _playingSub = player.stream.playing.listen(_handlePlayingState);
    _completedSub = player.stream.completed.listen(_handleCompletion);
    _positionSub = player.stream.position.listen(_handlePositionChange);
    _durationSub = player.stream.duration.listen(_handleDurationChange);
    _bufferSub = player.stream.buffer.listen(_handleBufferChange);
    _rateSub = player.stream.rate.listen(_handleRateChange);
    _bufferingSub = player.stream.buffering.listen(_handleBufferingState);
    _volumeSub = player.stream.volume.listen(_handleVolumeChange);

    _errorSub = player.stream.error.listen((String error) {
      log(
        error,
        name: logName,
        error: error,
      );
    });
  }

  void _emit(AudioEvent event) {
    _eventController.add(event);
  }

  void _handleMediaItemChange(MediaItem? media) {
    if (media == null || media.id.isEmpty) return;
    _mediaRepository.setAudioUrl(media.id);
    _mediaRepository.setVideoUrl(media.extras?['videoUrl'] as String?);
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

    if (!value) {
      _lastPositionSave = DateTime.now();
      _mediaRepository.setPosition(playbackState.value.updatePosition);
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
          return;

        case AudioServiceRepeatMode.all:
          if (_mediaQueue.isNotEmpty) {
            if (_currentIndex >= _mediaQueue.length - 1) {
              log("Repeat all: restarting queue from beginning", name: logName);
              skipToQueueItem(0);
            } else {
              log("Repeat all: playing next track", name: logName);
              skipToNext();
            }
            return;
          }
          break;

        default:
          if (_currentIndex < _mediaQueue.length - 1) {
            log("No repeat: playing next track", name: logName);
            skipToNext();
            return;
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
  }

  void _handlePositionChange(Duration value) {
    //log("Position: $value", name: logName);
    playbackState.add(playbackState.value.copyWith(
      updatePosition: value,
    ));

    final now = DateTime.now();
    if (_lastPositionSave == null ||
        now.difference(_lastPositionSave!) >= _saveInterval) {
      _mediaRepository.setPosition(value);
      _lastPositionSave = now;
    }
  }

  void _handleDurationChange(Duration value) {
    log("Duration: $value", name: logName);
    mediaItem.add(mediaItem.value?.copyWith(duration: value));
  }

  void _handleRateChange(double value) {
    log("Playback rate: $value", name: logName);
    playbackState.add(playbackState.value.copyWith(
      speed: value,
    ));
    _mediaRepository.setRate(value);
  }

  void _handleBufferChange(Duration value) {
    //log("Buffer: $value", name: logName);
    playbackState.add(playbackState.value.copyWith(
      bufferedPosition: value,
    ));
  }

  void _handleBufferingState(bool value) {
    log(value ? "Buffering" : "Done buffering", name: logName);
    playbackState.add(playbackState.value.copyWith(
      processingState:
          value ? AudioProcessingState.buffering : AudioProcessingState.ready,
    ));
  }

  void _handleVolumeChange(double value) {
    log("Volume: $value", name: logName);
    _mediaRepository.setVolume(value);
  }

  Future<void> loadMedia({
    String? audioUrl,
    String? videoUrl,
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
    log("VideoUrl: $videoUrl", name: logName);
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

    _emit(AudioEvent.mediaItemChanged);

    final playbackUrl = (videoUrl != null && videoUrl.isNotEmpty)
        ? videoUrl
        : audioUrl;

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
      },
    );

    // Open media FIRST so VideoController is ready when UI rebuilds
    await _player.open(
      playbackUrl,
      startPosition: startPosition,
      autoplay: autoplay,
    );

    // Then notify UI (VideoController is ready)
    mediaItem.add(media);
  }

  @override
  Future<void> play() async {
    _emit(AudioEvent.play);
    await _player.play();
  }

  @override
  Future<void> pause() async {
    _emit(AudioEvent.pause);
    await _player.pause();
  }

  Future<void> playOrPause() async {
    if (playbackState.value.playing) {
      await pause();
    } else {
      await play();
    }
  }

  @override
  Future<void> stop() async {
    _emit(AudioEvent.stop);
    await _player.stop();
    super.stop();
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setRate(speed);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  @override
  Future<void> seek(Duration position) async {
    _emit(AudioEvent.seek);
    await _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    log("Skipping to next", name: logName);

    final queueLength = _mediaQueue.length;
    if (_isShuffling) {
      if (queueLength <= 1) {
        log("No items to shuffle", name: logName);
        return;
      }
      int newIndex;
      do {
        newIndex = Random().nextInt(queueLength);
      } while (newIndex == _currentIndex);

      await skipToQueueItem(newIndex);
    } else if (_currentIndex < queueLength - 1) {
      final nextIndex = _currentIndex + 1;
      await skipToQueueItem(nextIndex);
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
    final videoUrl = media.extras?['videoUrl'] as String?;

    await loadMedia(
      audioUrl: media.id,
      videoUrl: videoUrl,
      podcastTitle: media.artist,
      podcastRSS: media.extras?["podcastRSS"],
      episodeTitle: media.title,
      album: media.album,
      description: media.displayDescription,
      artist: media.artist,
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
    log("Added to queue: ${mediaItem.id}", name: logName);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    for (var item in mediaItems) {
      _mediaQueue.add(item);
      log("Added to queue: ${item.id}", name: logName);
    }
    queue.add(_mediaQueue);
  }

  Future<void> addToQueue({
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
    log("Adding to queue", name: logName);
    log("AudioUrl: $audioUrl", name: logName);
    log("VideoUrl: $videoUrl", name: logName);
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
      extras: {
        "podcastRSS": podcastRSS,
        "videoUrl": videoUrl,
      },
    );

    await addQueueItem(media);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= _mediaQueue.length) {
      log("Index out of bounds: $index", name: logName);
      return;
    }
    _mediaQueue.removeAt(index);
    queue.add(_mediaQueue);

    if (_currentIndex >= index) {
      _currentIndex--;
    }

    log("Removed from queue: index $index", name: logName);
  }

  Future<void> clearQueue() async {
    _mediaQueue.clear();
    queue.add(_mediaQueue);
    log("Cleared queue", name: logName);
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = _mediaQueue.indexOf(mediaItem);
    if (index == -1) {
      log("Item not found in queue", name: logName);
      return;
    }
    await removeQueueItemAt(index);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    log("Setting repeat mode: $repeatMode", name: logName);

    _repeatMode = repeatMode;

    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    log("Shuffle mode: $shuffleMode", name: logName);

    _isShuffling = shuffleMode == AudioServiceShuffleMode.all;

    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
  }

  @override
  Future<void> onTaskRemoved() async {
    log("Task removed, saving position", name: logName);
    _mediaRepository.setPosition(playbackState.value.updatePosition);
    await stop();
  }

  Future<void> dispose() async {
    log("Disposing media", name: logName);
    await _mediaItemSub.cancel();
    await _playingSub.cancel();
    await _completedSub.cancel();
    await _positionSub.cancel();
    await _durationSub.cancel();
    await _bufferSub.cancel();
    await _rateSub.cancel();
    await _bufferingSub.cancel();
    await _volumeSub.cancel();
    await _errorSub.cancel();
    _eventController.close();
    await _player.dispose();
  }
}
