abstract class ISyncRepository {
  Future<void> addPendingEpisodeAction({
    required String podcastRss,
    required String episodeUrl,
    required String action,
    int position = 0,
    DateTime? timestamp,
  });

  Future<List<Map<String, dynamic>>> getPendingEpisodeActions();

  Future<void> deletePendingEpisodeActions(List<int> ids);

  Future<void> clearPendingEpisodeActions();

  Future<void> addPendingSubscriptionAction(String rss, String action);

  Future<List<Map<String, dynamic>>> getPendingSubscriptionActions();

  Future<void> deletePendingSubscriptionActions(List<int> ids);

  Future<void> clearPendingSubscriptionActions();
}
