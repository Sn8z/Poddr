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

  // Video support
  final String? videoUrl;
  final String? videoLocalPath;
  final int? videoFileSize;

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
    this.videoUrl,
    this.videoLocalPath,
    this.videoFileSize,
  });

  OfflineEpisode copyWith({
    int? id,
    String? audioUrl,
    String? localPath,
    String? title,
    String? description,
    String? imageUrl,
    String? podcastTitle,
    String? podcastRSS,
    int? duration,
    int? fileSize,
    DateTime? downloadedAt,
    DateTime? publicationDate,
    String? videoUrl,
    String? videoLocalPath,
    int? videoFileSize,
  }) {
    return OfflineEpisode(
      id: id ?? this.id,
      audioUrl: audioUrl ?? this.audioUrl,
      localPath: localPath ?? this.localPath,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      podcastTitle: podcastTitle ?? this.podcastTitle,
      podcastRSS: podcastRSS ?? this.podcastRSS,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      publicationDate: publicationDate ?? this.publicationDate,
      videoUrl: videoUrl ?? this.videoUrl,
      videoLocalPath: videoLocalPath ?? this.videoLocalPath,
      videoFileSize: videoFileSize ?? this.videoFileSize,
    );
  }
}
