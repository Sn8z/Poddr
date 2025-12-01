abstract class IMediaRepository {
  void setRate(double rate);
  double getRate();

  void setVolume(double volume);
  double getVolume();

  void setPosition(Duration position);
  Duration getPosition();

  void setId(String id);
  String getId();

  void setRSS(String rss);
  String getRSS();

  void setPodcastTitle(String title);
  String getPodcastTitle();

  void setEpisodeTitle(String title);
  String getEpisodeTitle();

  void setAuthor(String author);
  String getAuthor();

  void setArtwork(String uri);
  String getArtwork();
}
