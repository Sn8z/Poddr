class Genre {
  final String id;
  final String name;
  const Genre({required this.id, required this.name});

  Genre copyWith({
    String? id,
    String? name,
  }) {
    return Genre(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
