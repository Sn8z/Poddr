angular.module('poddr').controller(
  "PodcastController", function($scope, $http){

    $scope.region = "us";
    $scope.podcasts = [];
    $scope.countries = ["us", "gb", "se", "fr", "es"];

    $scope.getPodcasts = function(){
      $scope.podcasts = [];
      $http.get("https://itunes.apple.com/" + $scope.region + "/rss/toppodcasts/limit=25/json").then(function(response){
        $scope.podcasts = response.data.feed.entry;
      });
    }
    $scope.getPodcasts();
});
