angular
  .module("poddr")
  .controller("EpisodesController", function (
    $scope,
    $rootScope,
    $http,
    $filter,
    $mdSidenav,
    ToastService,
    PlayerService,
    PrevPlayedFactory
  ) {
    var parsePodcast = require("node-podcast-parser");
    var log = require("electron-log");

    //Calculating number of episodes to load by default based on application outer height, 55px is min height of a episode element.
    const EPISODE_BASE_LIMIT = Math.floor(window.outerHeight / 55);
    $scope.limit = EPISODE_BASE_LIMIT;
    $scope.query = "";

    $scope.prevPlayedEpisodes = PrevPlayedFactory.getGUIDs();

    $scope.podcastCover = "";
    $scope.isLoading = false;
    $scope.playPodcast = $rootScope.playPodcast;
    $scope.episodes = [];
    var allEpisodes = [];

    var closeSidenav = function () {
      $mdSidenav("right").close();
    }
    $scope.closeSidenav = closeSidenav;

    $rootScope.fetchEpisodes = function (id, title, podcastCover) {
      log.info("Fetching episodes for " + title + "...");
      PlayerService.latestSeenArtist = title;
      PlayerService.latestSeenID = id.toString();
      PlayerService.latestSeenCover = podcastCover;
      $scope.podcastCover = podcastCover;
      $scope.limit = EPISODE_BASE_LIMIT;
      $scope.query = "";

      $scope.episodeTitle = PlayerService.latestSeenArtist;
      $scope.episodes = [];
      allEpisodes = [];
      $scope.isLoading = true;
      $mdSidenav("right")
        .open()
        .then(function () {
          log.info("Looking up iTunes id: " + id);
          $http
            .get("https://itunes.apple.com/lookup?id=" + id, { timeout: 20000 })
            .then(
              function successCallback(response) {
                log.info("Found iTunes data.");
                log.info("Getting podcastfeed...");
                $http
                  .get(response.data.results[0].feedUrl)
                  .then(
                    function successCallback(response) {
                      log.info("Successfully fetched podcastfeed.");
                      log.info("Parsing podcastfeed...");
                      parsePodcast(response.data, function (error, data) {
                        if (error) {
                          ToastService.errorToast(
                            "Parsing podcastfeed failed."
                          );
                          log.error(error);
                        } else {
                          $scope.episodes = data.episodes;
                          allEpisodes = angular.copy(data.episodes);
                          log.info(
                            "Parsed " + $scope.episodes.length + " episodes."
                          );
                        }
                      });
                    },
                    function errorCallback(error) {
                      ToastService.errorToast(
                        "Failed to get podcast RSS feed."
                      );
                      log.error(error);
                    }
                  )
                  .finally(function () {
                    $scope.isLoading = false;
                  });
              },
              function errorCallback(error) {
                $scope.isLoading = false;
                ToastService.errorToast("Failed to lookup " + id + " in iTunes.");
                log.error(error);
              }
            );
        });
    };

    $scope.isPlayed = function (id) {
      return $scope.prevPlayedEpisodes["prevGUIDs"]["guids"]
        ? $scope.prevPlayedEpisodes["prevGUIDs"]["guids"].indexOf(id) !== -1
        : false;
    };

    //Filter episodes
    $scope.filterEpisodes = function () {
      $scope.episodes = $filter("filter")(allEpisodes, $scope.query);
    };

    //Toggle order based on publish date
    $scope.toggleOrder = true;
    $scope.toggleOrderBy = function () {
      $scope.toggleOrder = !$scope.toggleOrder;
      if ($scope.toggleOrder) {
        $scope.episodes = $filter("orderBy")($scope.episodes, "-published");
      } else {
        $scope.episodes = $filter("orderBy")($scope.episodes, "published");
      }
    };

    //Fetch and render more episodes as the user scrolls the episode list
    var episodeNav = document.getElementById("right-sidenav");
    var loadMoreEpisodes = function () {
      //check if scroll is at bottom & if there is more episodes to load
      if (
        episodeNav.scrollTop ===
        episodeNav.scrollHeight - episodeNav.offsetHeight &&
        $scope.limit < $scope.episodes.length
      ) {
        $scope.limit += 10;
        $scope.$digest();
      }
    };

    //Listen for the scroll event of the episode list
    episodeNav.addEventListener("scroll", loadMoreEpisodes);

    //Check if we need to load more episodes when the window size changes
    window.addEventListener("resize", loadMoreEpisodes);
  });
