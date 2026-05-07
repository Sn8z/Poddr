import 'package:media_kit/media_kit.dart';
import 'package:poddr/core/log.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:poddr/ui/utils/platform.dart';

class PoddrMediaPlayer {
  static const String logName = "PoddrMediaPlayer";

  late final Player _player;
  Player get player => _player;
  VideoController? _videoController;
  VideoController? get videoController {
    _videoController ??= VideoController(_player);
    return _videoController;
  }

  PoddrMediaPlayer() {
    _player = Player(
      configuration: PlayerConfiguration(
        title: "Poddr",
        ready: () => debug("AudioPlayer ready", name: "AudioPlayer"),
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

      if (isMobile) {
        await _player.setVolume(100);
      } else {
        await _player.setVolume(volume);
      }

      if (!isWeb) {
        await _player.setAudioDevice(AudioDevice.auto());
      }

      info("Player initialized", name: logName);
    } catch (e, stackTrace) {
      error(
        "Error initializing player",
        name: logName,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> open(
    String url, {
    Duration startPosition = Duration.zero,
    bool autoplay = true,
  }) async {
    debug("Opening: $url", name: logName);

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
    if (isMobile) return;
    await _player.setVolume(volume.clamp(0.0, 100.0));
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    debug("Disposing player", name: logName);
    _videoController = null;
    await _player.dispose();
  }
}
