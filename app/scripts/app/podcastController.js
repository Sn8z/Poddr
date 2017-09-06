angular.module('poddr').controller(
  "PodcastController", function($scope, $http){

    $scope.genre = "music";

    $scope.tags = ["music", "gaming", "finance", "tv-film", "science-medicine",
    "geek", "education", "news-politics", "esports", "edm"];

    $scope.getPodcasts = function(){
      $http.get("https://gpodder.net/api/2/tag/" + $scope.genre + "/25.json").then(function(response){
        $scope.podcasts = response.data;
      });
    }
    $scope.getPodcasts();
});
