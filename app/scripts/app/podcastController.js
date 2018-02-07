angular.module('poddr').controller(
  "PodcastController", function($scope, $http, $mdToast, $rootScope, RegionService){
    var storage = require('electron-json-storage');
    $scope.amount = 50;
    $scope.podcasts = [];

    $scope.countries = RegionService.regions;
    $scope.region = "us";

    storage.get('region', function(error, data) {
      if (error) throw error;
      if(data.value.length > 0){
        $scope.region = data.value;
      }
      $scope.$apply();
      $scope.getPodcasts();
    });

    $scope.getPodcasts = function(){
      $scope.podcasts = [];
      $http.get("https://itunes.apple.com/" + $scope.region + "/rss/toppodcasts/limit=" + $scope.amount + "/json").then(function(response){
        $scope.podcasts = response.data.feed.entry;
        console.log($scope.podcasts);
      });
    }

    $scope.showEpisodes = function(id){
      $rootScope.fetchEpisodes(id);
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
    }
});
