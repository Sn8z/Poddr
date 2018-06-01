angular
  .module("poddr")
  .controller("FavouritesController", function (
    $scope,
    $rootScope,
    ToastService
  ) {
    var storage = require("electron-json-storage");

    $scope.message = "";
    $scope.favourites = [];
    storage.getAll(function (err, data) {
      if (err) {
        console.log(err);
      } else {
        //simplest way to avoid fetching all data (not that pretty...)
        delete data.volume;
        delete data.region;
        delete data.theme;
        $scope.favourites = data;
        if ($scope.favourites.length == 0) {
          $scope.message = "No favourites added yet..";
        }
        $scope.$apply();
      }
    });

    $scope.showEpisodes = $rootScope.fetchEpisodes;

    $scope.removeFavourite = function (id) {
      ToastService.confirmToast("Are you sure?", function (response) {
        if (response) {
          storage.remove(id, function (err) {
            if (err) {
              console.log(err);
              ToastService.errorToast("Couldn't remove favourite.");
            } else {
              delete $scope.favourites[id];
              $scope.$apply();
            }
          });
        }
      });
    };
  });
