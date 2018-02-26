angular
  .module("poddr")
  .controller("SearchController", function(
    $scope,
    $http,
    $mdToast,
    $rootScope,
    $window,
    $timeout
  ) {
    var storage = require("electron-json-storage");

    $scope.query = "";
    $scope.results = [];

    $scope.isLoading = false;
    $scope.isEmpty = false;

    //Set focus on input everytime this view gets rendered
    $timeout(function() {
      $window.document.getElementById("search-input").focus();
    }, 50);

    $scope.showEpisodes = function(id, img) {
      $rootScope.fetchEpisodes(id, img);
      $rootScope.toggleSidebar();
    };

    $scope.doSearch = function() {
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
          .then(function(response) {
            $scope.isLoading = false;
            $scope.results = response.data.results;
            if ($scope.results.length == 0) {
              $scope.isEmpty = true;
            }
          });
      }
    };

    $scope.setFavourite = $rootScope.setFavourite;
    $scope.setFavourite = function(id, img, title, artist) {
      id = id.toString();
      storage.set(
        id,
        {
          id: id,
          title: title,
          img: img,
          artist: artist
        },
        function(err) {
          if (err) {
            console.log(err);
          } else {
            $mdToast.show(
              $mdToast
                .simple()
                .textContent("You now follow " + artist)
                .position("top right")
                .hideDelay(3000)
                .toastClass("md-toast-success")
            );
          }
        }
      );
    };
  });
