import 'dart:developer';

import 'package:poddr/data/media/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsMediaRepository implements IMediaRepository {
  final String logName = "SharedPrefsMediaRepository";
  SharedPreferences? _prefs;

  SharedPrefsMediaRepository() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    log("Initialized repository", name: logName);
  }

  @override
  void setRate(double rate) {
    _prefs?.setDouble("rate", rate);
  }

  @override
  double getRate() {
    return _prefs?.getDouble("rate") ?? 1.0;
  }

  @override
  void setVolume(double volume) {
    _prefs?.setDouble("volume", volume);
  }

  @override
  double getVolume() {
    return _prefs?.getDouble("volume") ?? 50;
  }

  @override
  void setPosition(Duration position) {
    _prefs?.setInt("position", position.inSeconds);
  }

  @override
  Duration getPosition() {
    return Duration(seconds: _prefs?.getInt("position") ?? 0);
  }

  @override
  void setId(String id) {
    _prefs?.setString("id", id);
  }

  @override
  String getId() {
    return _prefs?.getString("id") ?? "";
  }

  @override
  void setRSS(String rss) {
    _prefs?.setString("rss", rss);
  }

  @override
  String getRSS() {
    return _prefs?.getString("rss") ?? "";
  }

  @override
  void setPodcastTitle(String title) {
    _prefs?.setString("podcastTitle", title);
  }

  @override
  String getPodcastTitle() {
    return _prefs?.getString("podcastTitle") ?? "";
  }

  @override
  void setEpisodeTitle(String title) {
    _prefs?.setString("episodeTitle", title);
  }

  @override
  String getEpisodeTitle() {
    return _prefs?.getString("episodeTitle") ?? "";
  }

  @override
  void setAuthor(String author) {
    _prefs?.setString("author", author);
  }

  @override
  String getAuthor() {
    return _prefs?.getString("author") ?? "";
  }

  @override
  void setArtwork(String uri) {
    _prefs?.setString("artwork", uri);
  }

  @override
  String getArtwork() {
    return _prefs?.getString("artwork") ?? "";
  }
}
