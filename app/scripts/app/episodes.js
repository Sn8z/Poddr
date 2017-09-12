angular.module('poddr').controller(
  "EpisodesController", function($scope, $rootScope, $http){
    const parsePodcast = require('node-podcast-parser');

    $scope.isLoading = false;

    $scope.playPodcast = $rootScope.playPodcast;
    $scope.episodes = [];

    $scope.toggleEpisodes = function(){
      $('#' + $scope.podcastid).toggle();
      if($scope.episodes.length == 0){
        fetchEpisodes();
      }
    }

    function fetchEpisodes(){
      $scope.isLoading = true;
      $http.get("https://itunes.apple.com/lookup?id=" + $scope.podcastid ).then(function(response){
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
