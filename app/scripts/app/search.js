angular
  .module("poddr")
  .controller("SearchController", function(
    $scope,
    $http,
    $rootScope,
    $filter,
    $window,
    $timeout,
    FavouriteService,
    FavouriteFactory
  ) {
    var log = require("electron-log");
    var parsePodcast = require("node-podcast-parser");

    $scope.query = "";
    $scope.results = [];

    $scope.isLoading = false;
    $scope.isEmpty = false;

    //Set focus on input everytime this view gets rendered
    $timeout(function() {
      $window.document.getElementById("search-input").focus();
    }, 50);

    $scope.showEpisodes = $rootScope.fetchEpisodes;

    var getDescription = function(podcast){
      if(podcast.feedURL !== null && podcast.feedUrl.length){
        $http.get(podcast.feedUrl, {timeout: 20000})
          .then(function(response){
            parsePodcast(response.data, function(error, data) {
              if (error) {
                log.error(error);
                podcast.description = "No description available";
              } else {
                if(data.description.long !== null && data.description.long.length){
                  podcast.description = $filter("episodeDesc")(data.description.long);
                } else {
                  podcast.description = "No description available";
                }
              }
            });
          }, function(error){
            log.error(error);
            podcast.description = "No description available";
          });
      } else {
        podcast.description = "No description available";
      }
    };

    $scope.doSearch = function() {
      if ($scope.query) {
        log.info("Searching for " + $scope.query + "...");
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
              "&entity=podcast&attributes=titleTerm,artistTerm",
              {timeout: 20000}
          )
          .then(function successCallback(response) {
            $scope.results = response.data.results;
            angular.forEach($scope.results, function(result){
              getDescription(result);
            });
            log.info("Found " + $scope.results.length + " matches for " + $scope.query);
            if ($scope.results.length == 0) {
              $scope.isEmpty = true;
            }
          }, function errorCallback(error){
            log.error(error);
          }).finally(function(){
            $scope.isLoading = false;
          });
      }
    };
    $scope.setFavourite = FavouriteService.favourite;

    $scope.favouriteList = FavouriteFactory.getList();
    $scope.isFavourite = function(id) {
      return $scope.favouriteList.keys.indexOf(id) !== -1;
    };
  });
