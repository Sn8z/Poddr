angular.module('poddr').controller(
  "PodcastController", function($scope, $rootScope, $http){

    $scope.amount = 50;
    $scope.region = "us";
    $scope.podcasts = [];

    //TODO: move to service
    $scope.countries = ["us", "gb", "se", "fr", "es"];

    $scope.getPodcasts = function(){
      $scope.podcasts = [];
      $http.get("https://itunes.apple.com/" + $scope.region + "/rss/toppodcasts/limit=" + $scope.amount + "/json").then(function(response){
        $scope.podcasts = response.data.feed.entry;
      });
    }
    $scope.getPodcasts();

    var storage = require('electron-json-storage');
    $scope.setFavourite = function(id, img, title, artist){
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
