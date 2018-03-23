angular
  .module("poddr")
  .controller("EpisodesController", function (
    $scope,
    $rootScope,
    $http,
    $mdSidenav,
    ToastService
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

    $rootScope.fetchEpisodes = function (id, podcastCover) {
      $scope.albumCover = podcastCover;
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
                    console.log(err);
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
                console.log(response);
                $scope.isLoading = false;
                ToastService.errorToast("Something went wrong");
              }
            );
          },
          function errorCallback(response) {
            console.log(response);
            $scope.isLoading = false;
            ToastService.errorToast("Something went wrong");
          }
        );
      });
    };
  });
