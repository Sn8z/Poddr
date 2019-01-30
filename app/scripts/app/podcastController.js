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
    const Store = require("electron-store");
    const store = new Store();
    var log = require('electron-log');
    $scope.amount = 50;
    $scope.podcasts = [];

    $scope.genres = GenreService.genres;
    $scope.genre = 26;

    $scope.layout = store.get("layout", "grid");
    $scope.region = store.get("region", "us");
    $scope.countries = [];
    RegionService.regions(function (data) {
      $scope.countries = data;
      $scope.$digest();
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
          , { timeout: 20000 })
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

    $scope.getPodcasts();

    $scope.showEpisodes = $rootScope.openEpisodesWithID;
    $scope.setFavourite = FavouriteService.favouriteItunesId;

    $scope.favouriteList = FavouriteFactory.getList();
    $scope.isFavourite = function (title) {
      return $scope.favouriteList.titles.indexOf(title) !== -1;
    };
  });
