angular.module('poddr').controller(
  "FavouritesController", function($scope){
    var storage = require('electron-json-storage');

    $scope.title = "Favourites";
    $scope.favourites = {};
    storage.getAll(function(err, data){
      if(err){
        console.log(err);
      } else {
        $scope.favourites = data;
        $scope.$apply();
      }
    });

    $scope.removeFavourite = function(id){
      storage.remove(id, function(err){
        if(err){
          console.log(err);
          }
      });
    }

  });
