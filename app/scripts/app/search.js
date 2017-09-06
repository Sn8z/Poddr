angular.module('poddr').controller(
  "SearchController", function($scope, $http){
    $scope.query = "";
    $scope.results = [];

  function doSearch(){
    if($scope.query){
      $http.get("https://gpodder.net/search.json?q=" + $scope.query).then(function(response){
        $scope.results = response.data;
      })
    } else {
      $scope.results = [];
    }
  }
  $scope.doSearch = doSearch;

  });
