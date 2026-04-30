import 'package:poddr/models/country.dart';

abstract class ICountryRepository {
  List<Country> getCountries();
}
