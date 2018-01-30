angular.module('poddr').controller(
  "EpisodesController", function($scope, $rootScope, $http){
    const parsePodcast = require('node-podcast-parser');

    $scope.isLoading = false;

    $scope.playPodcast = $rootScope.playPodcast;
    $scope.episodes = [];

    //pagination
    $scope.pageSize = 10;
    $scope.currentPage = 0;

    $scope.numberOfPages = function(){
      return Math.ceil($scope.episodes.length / $scope.pageSize);
    }

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
              console.log(data.episodes);
              $scope.isLoading = false;
              $scope.episodes = data.episodes;
              $scope.totalItems = $scope.episodes.length;
            }
          });
        });
      });
    }
  });
