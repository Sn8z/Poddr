angular.module('poddr').controller(
  "EpisodesController", function($scope, $rootScope, $http){
    var parsePodcast = require('node-podcast-parser');

    $scope.isLoading = false;

    $scope.playPodcast = $rootScope.playPodcast;
    $scope.episodes = [];

    $rootScope.fetchEpisodes = function (id){
      $scope.episodes = [];
      $scope.isLoading = true;
      $http.get("https://itunes.apple.com/lookup?id=" + id).then(function(response){
        $http.get(response.data.results[0].feedUrl).then(function(response){
          parsePodcast(response.data, function(err, data){
            if(err){
              console.log(err);
            } else {
              $scope.isLoading = false;
              $scope.episodes = data.episodes;
            }
          });
        });
      });
    }
  });
