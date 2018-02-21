angular.module('poddr').controller(
  "FavouritesController", function($scope, $rootScope, $mdToast){
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

    $scope.showEpisodes = function(id, img){
      $rootScope.fetchEpisodes(id, img);
      $rootScope.toggleSidebar();
    }

    function setFavourite(id, img, title, artist) {
      id = id.toString();
      storage.set(id, {
        'id': id,
        'title': title,
        'img': img,
        'artist': artist
      }, function (err) {
        if (err) {
          console.log(err);
        } else {
          $mdToast.show(
            $mdToast.simple()
              .textContent("You now follow " + artist)
              .position("top right")
              .hideDelay(3000)
              .toastClass('md-toast-success')
          );
        }
      });
    }
    $rootScope.setFavourite = setFavourite;

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
              $event.srcElement.parentNode.parentElement.parentElement.parentElement.parentElement.remove();
            }
          });
        }
      });
    }
  });
