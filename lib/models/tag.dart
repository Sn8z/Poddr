class PodcastTag {
  final int id;
  final String name;
  final int color;

  const PodcastTag({
    required this.id,
    required this.name,
    required this.color,
  });

  PodcastTag copyWith({
    int? id,
    String? name,
    int? color,
  }) {
    return PodcastTag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}
