angular.module('poddr').controller(
  "PodcastController", function($scope, $http, $mdToast, $rootScope, RegionService, GenreService){
    var storage = require('electron-json-storage');
    $scope.amount = 50;
    $scope.podcasts = [];

    $scope.countries = RegionService.regions;

    $scope.genres = GenreService.genres;
    $scope.genre = 26;

    storage.get('region', function(error, data) {
      if (error){
        $scope.region = "us";
        console.log(error);
      }else{
        if (data.value) {
          $scope.region = data.value;
        } else {
          $scope.region = "us";          
        }
      }
      $scope.$apply();
      $scope.getPodcasts();
    });

    $scope.getPodcasts = function(){
      $scope.podcasts = [];
      $http.get("https://itunes.apple.com/" + $scope.region + "/rss/topaudiopodcasts/limit=" + $scope.amount + "/genre=" + $scope.genre + "/json").then(function(response){
        $scope.podcasts = response.data.feed.entry;
      });
    }

    $scope.showEpisodes = function(id, img){
      console.log(id + " " + img);
      $rootScope.fetchEpisodes(id, img);
      $rootScope.toggleSidebar();
    }

    $scope.setFavourite = function(id, img, title, artist){
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
