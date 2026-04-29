class OfflineEpisode {
  final int id;
  final String audioUrl;
  final String localPath;
  final String title;
  final String description;
  final String imageUrl;
  final String podcastTitle;
  final String podcastRSS;
  final int duration;
  final int fileSize;
  final DateTime downloadedAt;
  final DateTime? publicationDate;

  const OfflineEpisode({
    required this.id,
    required this.audioUrl,
    required this.localPath,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.podcastTitle,
    required this.podcastRSS,
    required this.duration,
    required this.fileSize,
    required this.downloadedAt,
    this.publicationDate,
  });
}
