angular.module('poddr').controller(
  "SearchController", function($scope, $http, $mdToast, $rootScope){
    var storage = require('electron-json-storage');
    var itunesSearch = require('itunes-api-search');

    $scope.query = "";
    $scope.results = [];

    $scope.isLoading = false;
    $scope.isEmpty = false;

    $scope.showEpisodes = function(id, img){
      $rootScope.fetchEpisodes(id, img);
      $rootScope.toggleSidebar();
    }

    $scope.doSearch = function(){
      if($scope.query){
        $scope.results = [];
        $scope.isLoading = true;
        $scope.isEmpty = false;
        itunesSearch.search($scope.query, {
          entity: 'podcast',
          limit: '50'
        }, function(err, res){
          if(err){
            console.log(err);
            return;
          }
          $scope.isLoading = false;
          $scope.results = res.results;
          if($scope.results.length == 0){$scope.isEmpty = true;}
          $scope.$apply();
        })
      }
    }

    $scope.setFavourite = $rootScope.setFavourite;
    $scope.setFavourite = function(id, img, title, artist){
      id = id.toString();
      storage.set(id,{
        'id': id,
        'title': title,
        'img': img,
        'artist': artist
      }, function(err){
        if(err){
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
    };

  });
