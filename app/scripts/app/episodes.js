angular
  .module("poddr")
  .controller("EpisodesController", function (
    $scope,
    $rootScope,
    $http,
    $mdSidenav,
    ToastService,
    PlayerService
  ) {
    var parsePodcast = require("node-podcast-parser");

    $scope.albumCover = "";
    $scope.isLoading = false;
    $scope.nrOfItems = 20;
    $scope.playPodcast = $rootScope.playPodcast;
    $scope.episodes = [];
    $scope.canLoadMore = false;

    $scope.loadMore = function () {
      $scope.nrOfItems += 10;
      if ($scope.episodes.length <= $scope.nrOfItems) {
        $scope.canLoadMore = false;
      }
    };

    $rootScope.fetchEpisodes = function (id, title, podcastCover) {
      PlayerService.latestSeenArtist = title;
      PlayerService.latestSeenID = id.toString();
      PlayerService.latestSeenCover = podcastCover;

      $scope.episodeTitle = PlayerService.latestSeenArtist;
      $scope.episodes = [];
      $scope.isLoading = true;
      $scope.nrOfItems = 20;
      $scope.canLoadMore = false;
      $mdSidenav("right").open().then(function () {
        $http.get("https://itunes.apple.com/lookup?id=" + id).then(
          function successCallback(response) {
            $http.get(response.data.results[0].feedUrl).then(
              function successCallback(response) {
                parsePodcast(response.data, function (err, data) {
                  if (err) {
                    $scope.isLoading = false;
                    ToastService.errorToast("Parsing podcastfeed failed.");
                  } else {
                    $scope.isLoading = false;
                    $scope.episodes = data.episodes;
                    if ($scope.episodes.length > $scope.nrOfItems) {
                      $scope.canLoadMore = true;
                    }
                  }
                });
              },
              function errorCallback(response) {
                $scope.isLoading = false;
                ToastService.errorToast("Failed to get podcast RSS feed.");
              }
            );
          },
          function errorCallback(response) {
            $scope.isLoading = false;
            ToastService.errorToast("Failed to lookup id in iTunes.");
          }
        );
      });
    };
  });
