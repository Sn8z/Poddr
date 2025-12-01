import 'dart:developer';
import 'package:media_kit/media_kit.dart';

class PoddrMediaPlayer {
  final String logName = "PoddrMediaPlayer";

  late final Player _player;
  Player get player => _player;

  PoddrMediaPlayer() {
    _player = Player(
      configuration: PlayerConfiguration(
        title: "Poddr",
        ready: () => log("AudioPlayer ready", name: "AudioPlayer"),
        logLevel: MPVLogLevel.info,
      ),
    );
  }

  Future<void> init({
    required double rate,
    required double volume,
  }) async {
    try {
      await _player.setRate(rate);
      await _player.setVolume(volume);
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
    bool autoplay = true,
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
    await _player.setVolume(volume);
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    log("Disposing player", name: logName);
    await _player.dispose();
  }
}
