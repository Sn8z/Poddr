import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart' hide AudioDevice;
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:poddr/services/history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaProvider extends BaseAudioHandler
    with QueueHandler, SeekHandler, ChangeNotifier {
  final Player _player = Player(
    configuration: PlayerConfiguration(
      title: "Poddr",
      ready: () => log("MediaHandler ready", name: "MediaProvider"),
      logLevel: MPVLogLevel.info,
    ),
  );

  //TODO: Improve check... Platform causes issues on web
  final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  final String logName = "MediaProvider";

  //TODO; Migrate to a repository pattern
  SharedPreferences? _prefs;

  AudioHandler? _audioHandler;

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

  final HistoryProvider historyProvider;

  MediaProvider({required this.historyProvider}) {
    _initAudioService();
    _initPlayer();
    _initStreams();
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
    _prefs = await SharedPreferences.getInstance();
    try {
      await _player.setRate(_prefs?.getDouble("mediaRate") ?? 1.0);
      if (isMobile) {
        await _player.setVolume(100);
      } else {
        await _player.setVolume(_prefs?.getDouble("mediaVolume") ?? 50);
      }
      await _player.setShuffle(false);
      await _player.setPlaylistMode(PlaylistMode.none);
      await _player.setAudioDevice(AudioDevice.auto());

      loadMedia(
        audioUrl: _prefs?.getString("mediaID") ?? "No audioUrl in storage",
        episodeTitle:
            _prefs?.getString("mediaTitle") ?? "No episodeTitle in storage",
        podcastTitle:
            _prefs?.getString("mediaArtist") ?? "No podcastTitle in storage",
        podcastRSS:
            _prefs?.getString("mediaPodcastRSS") ?? "No podcastRSS in storage",
        artUri: _prefs?.getString("mediaImage"),
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
    _prefs = await SharedPreferences.getInstance();

    mediaItem.listen(_handleMediaItemChange);
    _player.stream.playlist.listen(_handlePlaylistChange);
    _player.stream.playing.listen(_handlePlayingState);
    _player.stream.completed.listen(_handleCompletion);
    _player.stream.position.listen(_handlePositionChange);
    _player.stream.duration.listen(_handleDurationChange);
    _player.stream.buffer.listen(_handleBufferChange);
    _player.stream.rate.listen(_handleRateChange);
    _player.stream.buffering.listen(_handleBufferingState);
    _player.stream.error.listen(_handleError);

    if (!isMobile) {
      _player.stream.volume.listen(_handleVolumeChange);
    }
  }

  void _handleMediaItemChange(MediaItem? media) {
    if (media == null) return;
    _prefs?.setString("mediaID", media.id);
    _prefs?.setString("mediaTitle", media.title);
    _prefs?.setString("mediaArtist", media.artist ?? "");
    _prefs?.setString("mediaImage", media.artUri.toString());
    _prefs?.setString("mediaPodcastRSS", media.extras?["podcastRSS"] ?? "");
  }

  void _handlePlaylistChange(Playlist playlist) {
    log("Playlist update: $playlist", name: logName);
  }

  void _handlePlayingState(bool value) {
    log(value ? "Playing" : "Paused", name: logName);
    playbackState.add(playbackState.value.copyWith(
      playing: value,
      controls: value ? [MediaControl.pause] : [MediaControl.play],
    ));
    notifyListeners();

    if (!value) {
      saveProgress();
    }
  }

  void _handleCompletion(bool value) {
    log("Completed: $value", name: logName);
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
    _prefs?.setDouble("mediaRate", value);
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
    _prefs?.setDouble("mediaVolume", value);
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

    final media = MediaItem(
      id: audioUrl,
      title: episodeTitle ?? "Missing title",
      album: album ?? "Missing album",
      displayDescription: description ?? "Missing description",
      artist: artist ?? podcastTitle,
      artUri: Uri.parse(artUri ?? ""),
      extras: {"podcastRSS": podcastRSS},
    );

    final progress = await historyProvider.getProgress(media.id);
    if (progress != null) {
      startPosition = Duration(seconds: progress['position']);
    }

    mediaItem.add(media);
    await _player.open(
        Media(
          media.id,
          start: startPosition,
        ),
        play: false);

    if (progress == null) {
      historyProvider.addToHistory(
        media.id,
        media.title,
        media.displayDescription ?? "",
        media.artUri.toString(),
        podcastTitle ?? "",
        podcastRSS ?? "",
        _position.inSeconds,
        _duration.inSeconds,
        _position.inSeconds >= _duration.inSeconds,
      );
    }

    if (autoplay) await _player.play();
  }

  Future<void> setVolume(double volume) async {
    if (!isMobile) await _player.setVolume(volume);
  }

  void saveProgress() async {
    final media = mediaItem.value;
    if (media == null) return;
    await historyProvider.updateProgress(
      media.id,
      _position.inSeconds,
      _duration.inSeconds,
    );
    _prefs?.setInt("mediaPosition", _position.inSeconds);
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
    if (_player.state.playing) {
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
    await _player.next();
  }

  @override
  Future<void> skipToPrevious() async {
    await _player.previous();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    await _player.jump(index);
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
