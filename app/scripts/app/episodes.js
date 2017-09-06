angular.module('poddr').controller(
  "EpisodesController", function($scope, $rootScope, $http){

    $scope.playPodcast = $rootScope.playPodcast;
    $scope.episodes = [];
    $scope.album = $scope.podcast.logo_url;
    $http.get("http://feeds.gpodder.net/parse?url=" + $scope.podcast.url).then(function(response){
      $scope.episodes = response.data[0];
    })
  });
