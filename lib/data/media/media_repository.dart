abstract class IMediaRepository {
  Future<void> setRate(double rate);
  Future<double> getRate();

  Future<void> setVolume(double volume);
  Future<double> getVolume();

  Future<void> setPosition(Duration position);
  Future<Duration> getPosition();

  Future<void> setAudioUrl(String url);
  Future<String> getAudioUrl();

  Future<void> setRSS(String rss);
  Future<String> getRSS();

  Future<void> setPodcastTitle(String title);
  Future<String> getPodcastTitle();

  Future<void> setEpisodeTitle(String title);
  Future<String> getEpisodeTitle();

  Future<void> setAuthor(String author);
  Future<String> getAuthor();

  Future<void> setArtwork(String uri);
  Future<String> getArtwork();
}
