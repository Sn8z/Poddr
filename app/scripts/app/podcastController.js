angular
  .module("poddr")
  .controller("PodcastController", function(
    $scope,
    $http,
    $mdToast,
    $rootScope,
    RegionService,
    GenreService,
    ToastService,
    FavouriteService
  ) {
    var storage = require("electron-json-storage");
    $scope.amount = 50;
    $scope.podcasts = [];

    RegionService.regions(function(response) {
      $scope.countries = response;
    });

    $scope.genres = GenreService.genres;
    $scope.genre = 26;

    storage.get("region", function(error, data) {
      if (error) {
        $scope.region = "us";
      } else {
        if (data.value) {
          $scope.region = data.value;
        } else {
          $scope.region = "us";
        }
      }
      $scope.$apply();
      $scope.getPodcasts();
    });

    $scope.getPodcasts = function() {
      $scope.podcasts = [];
      $http
        .get(
          "https://itunes.apple.com/" +
            $scope.region +
            "/rss/topaudiopodcasts/limit=" +
            $scope.amount +
            "/genre=" +
            $scope.genre +
            "/json"
        )
        .then(
          function successCallback(response) {
            $scope.podcasts = response.data.feed.entry;
          },
          function errorCallback(response) {
            console.log("Error: " + response);
          }
        );
    };

    $scope.showEpisodes = function(id, img) {
      $rootScope.fetchEpisodes(id, img);
      $rootScope.toggleSidebar();
    };

    $scope.setFavourite = FavouriteService.favourite;
  });
