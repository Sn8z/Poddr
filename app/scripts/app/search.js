angular.module('poddr').controller(
  "SearchController", function($scope, $http, $mdToast){
    var itunesSearch = require('itunes-api-search');
    $scope.query = "";
    $scope.results = [];

    $scope.doSearch = function(){
      if($scope.query){
        itunesSearch.search($scope.query, {
          entity: 'podcast',
          limit: '25',
          country: 'SE'
        }, function(err, res){
          if(err){
            console.log(err);
            return;
          }
          console.log(res.results);
          $scope.results = res.results;
          $scope.$apply();
        })
      }
    }

  });
