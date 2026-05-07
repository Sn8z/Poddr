class Country {
  final String code;
  final String name;
  const Country({required this.code, required this.name});

  Country copyWith({
    String? code,
    String? name,
  }) {
    return Country(
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }
}
