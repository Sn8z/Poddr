angular
  .module("poddr")
  .controller("SearchController", function (
    $scope,
    $http,
    $rootScope,
    $window,
    $timeout,
    FavouriteService,
    FavouriteFactory
  ) {
    var log = require('electron-log');

    $scope.query = "";
    $scope.results = [];

    $scope.isLoading = false;
    $scope.isEmpty = false;

    //Set focus on input everytime this view gets rendered
    $timeout(function () {
      $window.document.getElementById("search-input").focus();
    }, 50);

    $scope.showEpisodes = $rootScope.fetchEpisodes;

    $scope.doSearch = function () {
      if ($scope.query) {
        log.info('Searching for ' + $scope.query + '...');
        $scope.results = [];
        $scope.isLoading = true;
        $scope.isEmpty = false;

        //replace åäö
        var sQuery = $scope.query.replace(/[\u00e4\u00c4\u00c5\u00e5]/g, "a");
        sQuery = sQuery.replace(/[\u00d6\u00f6]/g, "o");

        $http
          .get(
            "https://itunes.apple.com/search?term=" +
            sQuery +
            "&entity=podcast&attributes=titleTerm,artistTerm"
          )
          .then(function (response) {
            $scope.isLoading = false;
            $scope.results = response.data.results;
            log.info('Found ' + $scope.results.length + ' matches.');
            if ($scope.results.length == 0) {
              $scope.isEmpty = true;
            }
          });
      }
    };
    $scope.setFavourite = FavouriteService.favourite;

    $scope.favouriteList = FavouriteFactory.getList();
    $scope.isFavourite = function (id) {
      return $scope.favouriteList.keys.indexOf(id) !== -1;
    }
  });
