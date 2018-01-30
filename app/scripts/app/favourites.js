angular.module('poddr').controller(
  "FavouritesController", function($scope, $mdToast){
    var storage = require('electron-json-storage');

    $scope.title = "Favourites";
    $scope.favourites = {};
    storage.getAll(function(err, data){
      if(err){
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

    $scope.removeFavourite = function($event, id){

      var toast = $mdToast.simple()
        .textContent("Are you sure?")
        .position("top right")
        .hideDelay(10000)
        .action("Remove")
        .toastClass('md-toast-error')

      $mdToast.show(toast).then(function(response){
        if(response == 'ok'){
          storage.remove(id, function(err){
            if(err){
              console.log(err);
            } else {
              $event.currentTarget.parentNode.parentNode.parentNode.parentNode.remove();
            }
          });
        }
      });
    }
  });
