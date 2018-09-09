angular
  .module("poddr")
  .controller("EpisodesController", function (
    $scope,
    $rootScope,
    $http,
    $filter,
    $mdSidenav,
    ToastService,
    PlayerService
  ) {
    var parsePodcast = require("node-podcast-parser");
    var log = require('electron-log');

    const EPISODE_BASE_LIMIT = 20;
    $scope.limit = EPISODE_BASE_LIMIT;
    $scope.query = "";

    $scope.albumCover = "";
    $scope.isLoading = false;
    $scope.playPodcast = $rootScope.playPodcast;
    $scope.episodes = [];
    var allEpisodes = [];

    $rootScope.fetchEpisodes = function (id, title, podcastCover) {
      log.info('Fetching episodes...');
      PlayerService.latestSeenArtist = title;
      PlayerService.latestSeenID = id.toString();
      PlayerService.latestSeenCover = podcastCover;
      $scope.limit = EPISODE_BASE_LIMIT;
      $scope.query = "";

      $scope.episodeTitle = PlayerService.latestSeenArtist;
      $scope.episodes = [];
      allEpisodes = [];
      $scope.isLoading = true;
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
                    allEpisodes = angular.copy(data.episodes);
                    log.info('Parsed ' + $scope.episodes.length + ' episodes.');
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

    //Filter episodes
    $scope.filterEpisodes = function () {
      $scope.episodes = $filter('filter')(allEpisodes, $scope.query);
    }

    //Toggle order based on publish date
    $scope.toggleOrder = true;
    $scope.toggleOrderBy = function () {
      $scope.toggleOrder = !$scope.toggleOrder;
      if ($scope.toggleOrder) {
        $scope.episodes = $filter('orderBy')($scope.episodes, '-published');
      } else {
        $scope.episodes = $filter('orderBy')($scope.episodes, 'published');
      }
    }

    //Fetch and render more episodes as the user scrolls the episode list
    var episodeNav = document.getElementById('right-sidenav');
    var checkIfScrollAtBottom = function () {
      if (episodeNav.scrollTop === (episodeNav.scrollHeight - episodeNav.offsetHeight)) {
        $scope.limit += 10;
        $scope.$digest();
      }
    }
    episodeNav.addEventListener('scroll', checkIfScrollAtBottom);
    window.addEventListener('resize', checkIfScrollAtBottom);

  });
