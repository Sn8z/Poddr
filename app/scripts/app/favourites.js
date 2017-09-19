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

    $scope.removeFavourite = function($event, id){
      if(confirm("Are you sure?")){
      storage.remove(id, function(err){
        if(err){
          console.log(err);
        } else {
          $event.currentTarget.parentNode.parentNode.parentNode.parentNode.remove();
        }
      });
    }
  }
});
