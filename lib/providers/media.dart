import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart' hide AudioDevice;
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaProvider extends BaseAudioHandler
    with QueueHandler, SeekHandler, ChangeNotifier {
  final Player _player = Player(
    configuration: PlayerConfiguration(
      title: "Poddr",
      ready: () => debugPrint('MediaHandler ready'),
    ),
  );

  final isMobile = Platform.isAndroid || Platform.isIOS;

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

  MediaProvider() {
    initAudioService();
    _setupPlayer();
    _setupStreams();
  }

  Future<void> initAudioService() async {
    AudioSession.instance.then((AudioSession audioSession) {
      audioSession.configure(const AudioSessionConfiguration.speech());
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

  Future<void> _setupPlayer() async {
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

      final MediaItem mItem = MediaItem(
        id: _prefs?.getString("mediaID") ?? "",
        title: _prefs?.getString("mediaTitle") ?? "",
        artist: _prefs?.getString("mediaArtist") ?? "",
        artUri: Uri.parse(_prefs?.getString("mediaImage") ?? ""),
        duration: Duration(
          seconds: _prefs?.getInt("mediaDuration") ?? 0,
        ),
      );
      await _player.open(
        Media(
          mItem.id,
          start: Duration(seconds: _prefs?.getInt("mediaPosition") ?? 0),
        ),
        play: false,
      );
      mediaItem.add(mItem);
    } catch (e, s) {
      debugPrint('Exception details:\n $e');
      debugPrint('Stack trace:\n $s');
    }
  }

  void _setupStreams() async {
    _prefs = await SharedPreferences.getInstance();

    mediaItem.listen((MediaItem? media) {
      if (media == null) return;
      _prefs?.setString("mediaID", media.id);
      _prefs?.setString("mediaTitle", media.title);
      _prefs?.setString("mediaArtist", media.artist ?? "");
      _prefs?.setString("mediaImage", media.artUri.toString());
      _prefs?.setInt("mediaDuration", media.duration?.inSeconds ?? 0);
    });

    _player.stream.playlist.listen((e) {
      debugPrint("playlist: $e");
    });

    _player.stream.playing.listen((bool value) {
      debugPrint("playing: $value");
      playbackState.add(playbackState.value.copyWith(
        playing: value,
        controls: value ? [MediaControl.pause] : [MediaControl.play],
      ));
    });

    _player.stream.completed.listen((bool value) {
      debugPrint("completed: $value");
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.completed,
      ));
      _isLoading = false;
      notifyListeners();
    });

    _player.stream.position.listen((Duration value) {
      debugPrint("position: $value");
      playbackState.add(playbackState.value.copyWith(
        updatePosition: value,
      ));
      _prefs?.setInt("mediaPosition", value.inSeconds);
      _position = value;
      notifyListeners();
    });

    _player.stream.duration.listen((Duration value) {
      debugPrint("duration: $value");
      mediaItem.add(mediaItem.value?.copyWith(duration: value));
      _duration = value;
      notifyListeners();
    });

    _player.stream.buffer.listen((Duration value) {
      debugPrint("buffer: $value");
      playbackState.add(playbackState.value.copyWith(
        bufferedPosition: value,
      ));
      _bufferedPosition = value;
      notifyListeners();
    });

    _player.stream.rate.listen((double value) {
      debugPrint("rate: $value");
      playbackState.add(playbackState.value.copyWith(
        speed: value,
      ));
      _prefs?.setDouble("mediaRate", value);
      notifyListeners();
    });

    _player.stream.buffering.listen((bool value) {
      debugPrint("buffering: $value");
      playbackState.add(playbackState.value.copyWith(
        processingState:
            value ? AudioProcessingState.buffering : AudioProcessingState.ready,
      ));
      _isLoading = value;
      notifyListeners();
    });

    if (!isMobile) {
      _player.stream.volume.listen((double value) {
        debugPrint("volume: $value");
        _prefs?.setDouble("mediaVolume", value);
        _volume = value;
        notifyListeners();
      });
    }

    _player.stream.error.listen((String error) {
      debugPrint("Player error: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> loadMedia(MediaItem mItem) async {
    debugPrint("Loading media");
    debugPrint(mItem.toString());
    await _player.open(Media(mItem.id), play: false);
    mediaItem.add(mItem);
    await _player.play();
  }

  Future<void> setVolume(double volume) async {
    if (isMobile) return;
    await _player.setVolume(volume);
  }

  // Callbacks
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
  Future<void> seek(Duration position) async {
    await _player.seek(position);
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
    debugPrint("Disposing media");
    await _player.dispose();
    super.dispose();
  }
}
