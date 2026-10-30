/// A queued episode action waiting to be uploaded to the sync server.
typedef PendingEpisodeAction = ({
  int id,
  String podcastRss,
  String episodeUrl,
  String action,
  int position,
  int timestamp,
});

/// A queued subscription change waiting to be uploaded to the sync server.
typedef PendingSubscriptionAction = ({
  int id,
  String rss,
  String action,
  int timestamp,
});

abstract class ISyncRepository {
  Future<void> addPendingEpisodeAction({
    required String podcastRss,
    required String episodeUrl,
    required String action,
    int position = 0,
    DateTime? timestamp,
  });

  Future<List<PendingEpisodeAction>> getPendingEpisodeActions();

  Future<void> deletePendingEpisodeActions(List<int> ids);

  Future<void> clearPendingEpisodeActions();

  Future<void> addPendingSubscriptionAction(String rss, String action);

  Future<List<PendingSubscriptionAction>> getPendingSubscriptionActions();

  Future<void> deletePendingSubscriptionActions(List<int> ids);

  Future<void> clearPendingSubscriptionActions();
}
