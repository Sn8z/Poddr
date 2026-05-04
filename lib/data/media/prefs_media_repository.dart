import 'dart:developer';

import 'package:poddr/data/media/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsMediaRepository implements IMediaRepository {
  static const String logName = "SharedPrefsMediaRepository";

  @override
  Future<void> setRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    log("Saving rate: $rate", name: logName);
    prefs.setDouble("rate", rate);
  }

  @override
  Future<double> getRate() async {
    final prefs = await SharedPreferences.getInstance();

    final double rate = prefs.getDouble("rate") ?? 1.0;
    log("Loading rate $rate", name: logName);
    return rate;
  }

  @override
  Future<void> setVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();

    log("Saving volume: $volume", name: logName);
    prefs.setDouble("volume", volume);
  }

  @override
  Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();

    final double volume = prefs.getDouble("volume") ?? 50;
    log("Loading volume $volume", name: logName);
    return volume;
  }

  @override
  Future<void> setPosition(Duration position) async {
    final prefs = await SharedPreferences.getInstance();

    log("Saving position: $position", name: logName);
    prefs.setInt("position", position.inSeconds);
  }

  @override
  Future<Duration> getPosition() async {
    final prefs = await SharedPreferences.getInstance();

    final Duration position = Duration(seconds: prefs.getInt("position") ?? 0);
    log("Loading position $position", name: logName);
    return position;
  }

  @override
  Future<void> setAudioUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    log("Saving audio url: $url", name: logName);
    prefs.setString("audioUrl", url);
  }

  @override
  Future<String> getAudioUrl() async {
    final prefs = await SharedPreferences.getInstance();

    final String url = prefs.getString("audioUrl") ?? "";
    log("Loading audio url $url", name: logName);
    return url;
  }

  @override
  Future<void> setVideoUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    log("Saving video url: $url", name: logName);
    if (url == null) {
      await prefs.remove("videoUrl");
    } else {
      prefs.setString("videoUrl", url);
    }
  }

  @override
  Future<String?> getVideoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final String? url = prefs.getString("videoUrl");
    log("Loading video url $url", name: logName);
    return url;
  }

  @override
  Future<void> setRSS(String rss) async {
    final prefs = await SharedPreferences.getInstance();

    log("Saving rss: $rss", name: logName);
    prefs.setString("rss", rss);
  }

  @override
  Future<String> getRSS() async {
    final prefs = await SharedPreferences.getInstance();

    final String rss = prefs.getString("rss") ?? "";
    log("Loading rss $rss", name: logName);
    return rss;
  }

  @override
  Future<void> setPodcastTitle(String title) async {
    final prefs = await SharedPreferences.getInstance();

    log("Saving podcast title: $title", name: logName);
    prefs.setString("podcastTitle", title);
  }

  @override
  Future<String> getPodcastTitle() async {
    final prefs = await SharedPreferences.getInstance();

    final String title = prefs.getString("podcastTitle") ?? "";
    log("Loading podcast title $title", name: logName);
    return title;
  }

  @override
  Future<void> setEpisodeTitle(String title) async {
    final prefs = await SharedPreferences.getInstance();

    log("Saving episode title: $title", name: logName);
    prefs.setString("episodeTitle", title);
  }

  @override
  Future<String> getEpisodeTitle() async {
    final prefs = await SharedPreferences.getInstance();

    final String title = prefs.getString("episodeTitle") ?? "";
    log("Loading episode title $title", name: logName);
    return title;
  }

  @override
  Future<void> setAuthor(String author) async {
    final prefs = await SharedPreferences.getInstance();

    log("Saving author: $author", name: logName);
    prefs.setString("author", author);
  }

  @override
  Future<String> getAuthor() async {
    final prefs = await SharedPreferences.getInstance();

    final String author = prefs.getString("author") ?? "";
    log("Loading author $author", name: logName);
    return author;
  }

  @override
  Future<void> setArtwork(String uri) async {
    final prefs = await SharedPreferences.getInstance();

    log("Saving artwork: $uri", name: logName);
    prefs.setString("artwork", uri);
  }

  @override
  Future<String> getArtwork() async {
    final prefs = await SharedPreferences.getInstance();

    final String artwork = prefs.getString("artwork") ?? "";
    log("Loading artwork $artwork", name: logName);
    return artwork;
  }
}
