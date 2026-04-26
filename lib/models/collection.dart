class PodcastCollection {
  final int id;
  final String name;
  final int color;

  const PodcastCollection({
    required this.id,
    required this.name,
    required this.color,
  });

  PodcastCollection copyWith({
    int? id,
    String? name,
    int? color,
  }) {
    return PodcastCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}
