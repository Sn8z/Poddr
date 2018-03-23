angular
  .module("poddr")
  .controller("SearchController", function (
    $scope,
    $http,
    $mdToast,
    $rootScope,
    $window,
    $timeout,
    FavouriteService
  ) {
    $scope.query = "";
    $scope.results = [];

    $scope.isLoading = false;
    $scope.isEmpty = false;

    //Set focus on input everytime this view gets rendered
    $timeout(function () {
      $window.document.getElementById("search-input").focus();
    }, 50);

    $scope.showEpisodes = function (id, img) {
      $rootScope.fetchEpisodes(id, img);
    };

    $scope.doSearch = function () {
      if ($scope.query) {
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
            if ($scope.results.length == 0) {
              $scope.isEmpty = true;
            }
          });
      }
    };

    $scope.setFavourite = FavouriteService.favourite;
  });
