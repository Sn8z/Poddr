angular.module('poddr').controller(
  "PodcastController", function($scope, $http){

    var amount = 25;
    $scope.genre = "music";

    $scope.tags = ["music", "gaming", "finance", "tv-film", "science-medicine",
    "geek", "education", "news-politics", "esports", "edm"];

    $http.get("https://gpodder.net/api/2/tag/music/" + amount + ".json").then(function(response){
      $scope.podcasts = response.data;
    });
    $scope.title = "Top 25 - Music";

    $scope.showEpisodes = function(){
      alert("showing episodes");
    }
  });
