angular
  .module("poddr")
  .controller("PodcastController", function (
    $scope,
    $http,
    $rootScope,
    RegionService,
    GenreService,
    ToastService,
    FavouriteService,
    FavouriteFactory
  ) {
    var storage = require("electron-json-storage");
    $scope.amount = 50;
    $scope.podcasts = [];

    $scope.genres = GenreService.genres;
    $scope.genre = 26;

    RegionService.regions(function (response) {
      $scope.countries = response;
    });

    storage.get("region", function (error, data) {
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

    $scope.getPodcasts = function () {
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
            ToastService.errorToast("Couldn't fetch toplistfeed.");
          }
        );
    };

    $scope.showEpisodes = $rootScope.fetchEpisodes;

    $scope.setFavourite = FavouriteService.favourite;

    $scope.favouriteList = FavouriteFactory.getList();
    $scope.isFavourite = function (id) {
      return $scope.favouriteList.keys.indexOf(id) !== -1;
    }

  });
