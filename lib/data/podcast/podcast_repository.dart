import 'package:poddr/models/podcast.dart';

abstract class IPodcastRepository {
  Future<List<Podcast>> search(String query);

  Future<List<Podcast>> getCharts(String country, String genre);

  Future<Podcast> getFeed(String rss);
}
