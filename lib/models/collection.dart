class PodcastCollection {
  final int id;
  final String name;
  final int color;

  const PodcastCollection({
    required this.id,
    required this.name,
    required this.color,
  });

  @override
  String toString() => 'PodcastCollection{id: $id, name: $name, color: $color}';
}
