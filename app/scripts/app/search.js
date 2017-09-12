angular.module('poddr').controller(
  "SearchController", function($scope, $http, $mdToast){
    var itunesSearch = require('itunes-api-search');
    $scope.query = "";
    $scope.results = [];

    //TODO: move to service
    $scope.countries = ["us", "gb", "se", "fr", "es"];
    $scope.region = "us";

    $scope.isLoading = false;

    $scope.doSearch = function(){
      if($scope.query){
        $scope.results = [];
        $scope.isLoading = true;
        itunesSearch.search($scope.query, {
          entity: 'podcast',
          limit: '50',
          country: $scope.region
        }, function(err, res){
          if(err){
            //TODO display error to user in a friendly way
            console.log(err);
            return;
          }
          $scope.isLoading = false;
          $scope.results = res.results;
          $scope.$apply();
        })
      }
    }

    var storage = require('electron-json-storage');
    $scope.setFavourite = function(id, img, title, artist){
      var id = id.toString();
      storage.set(id,{
        'id': id,
        'title': title,
        'img': img,
        'artist': artist
      }, function(err){
        if(err){
          console.log(err);
        }
      });
    }

  });
