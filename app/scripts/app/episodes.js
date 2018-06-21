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
    var log = require('electron-log');

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
      log.info('Fetching episodes...');
      PlayerService.latestSeenArtist = title;
      PlayerService.latestSeenID = id.toString();
      PlayerService.latestSeenCover = podcastCover;

      $scope.episodeTitle = PlayerService.latestSeenArtist;
      $scope.episodes = [];
      $scope.isLoading = true;
      $scope.nrOfItems = 20;
      $scope.canLoadMore = false;
      $mdSidenav("right").open().then(function () {
        log.info("Looking up iTunes id: " + id);
        $http.get("https://itunes.apple.com/lookup?id=" + id).then(
          function successCallback(response) {
            log.info('Found iTunes data.');
            log.info('Getting podcastfeed...');
            $http.get(response.data.results[0].feedUrl).then(
              function successCallback(response) {
                log.info('Successfully fetched podcastfeed.');
                log.info('Parsing podcastfeed...');
                parsePodcast(response.data, function (error, data) {
                  if (error) {
                    $scope.isLoading = false;
                    ToastService.errorToast("Parsing podcastfeed failed.");
                    log.error(error);
                  } else {
                    $scope.isLoading = false;
                    $scope.episodes = data.episodes;
                    log.info('Parsed ' + $scope.episodes.length + ' episodes.');
                    if ($scope.episodes.length > $scope.nrOfItems) {
                      $scope.canLoadMore = true;
                    }
                  }
                });
              },
              function errorCallback(error) {
                $scope.isLoading = false;
                ToastService.errorToast("Failed to get podcast RSS feed.");
                log.error(error);
              }
            );
          },
          function errorCallback(error) {
            $scope.isLoading = false;
            ToastService.errorToast("Failed to lookup id in iTunes.");
            log.error(error);
          }
        );
      });
    };
  });
