import 'package:poddr/models/genre.dart';
import 'package:poddr/data/genres/genre_repository.dart';

class ItunesGenreRepository implements IGenreRepository {
  static const List<Genre> _genres = [
    Genre(id: "", name: "All"),
    Genre(id: "1301", name: 'Arts'),
    Genre(id: "1321", name: 'Business'),
    Genre(id: "1303", name: 'Comedy'),
    Genre(id: "1304", name: 'Education'),
    Genre(id: "1483", name: 'Fiction'),
    Genre(id: "1511", name: 'Government'),
    Genre(id: "1512", name: 'Health & Fitness'),
    Genre(id: "1487", name: 'History'),
    Genre(id: "1305", name: 'Kids & Family'),
    Genre(id: "1502", name: 'Leisure'),
    Genre(id: "1310", name: 'Music'),
    Genre(id: "1489", name: 'News'),
    Genre(id: "1314", name: 'Religion & Spirituality'),
    Genre(id: "1533", name: 'Science'),
    Genre(id: "1324", name: 'Society & Culture'),
    Genre(id: "1545", name: 'Sports'),
    Genre(id: "1309", name: 'TV & Film'),
    Genre(id: "1318", name: 'Technology'),
    Genre(id: "1488", name: 'True Crime'),
  ];

  @override
  List<Genre> getGenres() => _genres;
}
