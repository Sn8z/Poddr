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
    var log = require('electron-log');
    $scope.amount = 50;
    $scope.podcasts = [];
    $scope.layout = "grid";

    $scope.genres = GenreService.genres;
    $scope.genre = 26;

    RegionService.regions(function (response) {
      $scope.countries = response;
    });

    storage.get("region", function (error, data) {
      if (error) {
        log.error(error);
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
      log.info('Fetching podcasts...');
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
        , {timeout: 20000})
        .then(
          function successCallback(response) {
            $scope.podcasts = response.data.feed.entry;
            log.info('Found ' + $scope.podcasts.length + ' podcasts.');
          },
          function errorCallback(error) {
            log.error(error);
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
