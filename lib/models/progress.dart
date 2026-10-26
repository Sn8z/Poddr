/// Playback progress of a single episode.
class EpisodeProgress {
  final int position;
  final int duration;
  final bool isFinished;

  const EpisodeProgress({
    required this.position,
    required this.duration,
    required this.isFinished,
  });
}
