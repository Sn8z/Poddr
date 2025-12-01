import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

class PoddrMediaPlayer {
  final String logName = "PoddrMediaPlayer";

  final Player _player = Player(
    configuration: PlayerConfiguration(
      title: "Poddr",
      ready: () => log("AudioPlayer ready", name: "AudioPlayer"),
      logLevel: MPVLogLevel.info,
    ),
  );
  Player get player => _player;

  final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get isPlaying => _player.state.playing;
  Stream<bool> get playingStream => _player.stream.playing;
  Stream<bool> get completedStream => _player.stream.completed;
  Stream<Duration> get positionStream => _player.stream.position;
  Stream<Duration> get durationStream => _player.stream.duration;
  Stream<Duration> get bufferStream => _player.stream.buffer;
  Stream<double> get rateStream => _player.stream.rate;
  Stream<bool> get bufferingStream => _player.stream.buffering;
  Stream<String> get errorStream => _player.stream.error;
  Stream<double>? get volumeStream => isMobile ? null : _player.stream.volume;

  Future<void> init({
    required double rate,
    required double volume,
  }) async {
    try {
      await _player.setRate(rate);

      if (isMobile) {
        await _player.setVolume(100);
      } else {
        await _player.setVolume(volume);
      }

      await _player.setAudioDevice(AudioDevice.auto());

      log("Player initialized", name: logName);
    } catch (error, stackTrace) {
      log(
        "Error initializing player",
        time: DateTime.now(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> open(
    String url, {
    Duration startPosition = Duration.zero,
    bool autoplay = false,
  }) async {
    log("Opening: $url", name: logName);
    await _player.open(
      Media(url, start: startPosition),
      play: autoplay,
    );
  }

  Future<void> play() async {
    await _player.play();
  }

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

  Future<void> setRate(double speed) async {
    await _player.setRate(speed);
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    if (!isMobile) {
      await _player.setVolume(volume);
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    log("Disposing player", name: logName);
    await _player.dispose();
  }
}
