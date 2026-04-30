import 'package:poddr/models/genre.dart';

abstract class IGenreRepository {
  List<Genre> getGenres();
}
