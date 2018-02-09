angular.module('poddr').controller(
  "EpisodesController", function($scope, $rootScope, $http){
    var parsePodcast = require('node-podcast-parser');

    $scope.isLoading = false;
    $scope.nrOfItems = 20;
    $scope.playPodcast = $rootScope.playPodcast;
    $scope.episodes = [];
    $scope.canLoadMore = false;

    $scope.loadMore = function(){
      $scope.nrOfItems += 10;
      if ($scope.episodes.length <= $scope.nrOfItems) {
        $scope.canLoadMore = false;
      }
    }

    $rootScope.fetchEpisodes = function (id){
      $scope.episodes = [];
      $scope.isLoading = true;
      $scope.nrOfItems = 20;
      $scope.canLoadMore = false;
      $http.get("https://itunes.apple.com/lookup?id=" + id).then(function(response){
        $http.get(response.data.results[0].feedUrl).then(function(response){
          parsePodcast(response.data, function(err, data){
            if(err){
              console.log(err);
            } else {
              $scope.isLoading = false;
              $scope.episodes = data.episodes;
              if ($scope.episodes.length > $scope.nrOfItems) {
                $scope.canLoadMore = true;
              }
            }
          });
        });
      });
    }
  });
