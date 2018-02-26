angular
  .module("poddr")
  .controller("FavouritesController", function(
    $scope,
    $rootScope,
    ToastService
  ) {
    var storage = require("electron-json-storage");

    $scope.title = "Favourites";
    $scope.favourites = [];
    storage.getAll(function(err, data) {
      if (err) {
        console.log(err);
      } else {
        //simplest way to avoid fetching all data (not that pretty...)
        delete data.volume;
        delete data.region;
        delete data.theme;
        $scope.favourites = data;
        $scope.$apply();
      }
    });

    $scope.showEpisodes = function(id, img) {
      $rootScope.fetchEpisodes(id, img);
      $rootScope.toggleSidebar();
    };

    $scope.removeFavourite = function($event, id) {
      ToastService.confirmToast("Are you sure?", function(response) {
        if (response) {
          storage.remove(id, function(err) {
            if (err) {
              console.log(err);
            } else {
              $event.srcElement.parentNode.parentElement.parentElement.parentElement.parentElement.remove();
            }
          });
        }
      });
    };
  });
