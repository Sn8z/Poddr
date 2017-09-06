//register poddr module
var app = angular.module('poddr').controller("PoddrController", function($scope){
  $scope.mainContent = "podcasts";
  function changeView(view){
    $scope.mainContent = view;
  }
  $scope.changeView = changeView;
});

app.directive('podcasts', function(){
  return {
    restrict: 'AE',
    replace: true,
    templateUrl: 'views/podcasts.html'
  }
})

app.directive('search', function(){
  return {
    restrict: 'AE',
    replace: true,
    templateUrl: 'views/search.html'
  }
})

app.directive('episodes', function () {
    return {
      restrict: 'AE',
      scope: true,
      link: function(scope, element, attrs){
        scope.podcast = attrs.data;
      },
      templateUrl: "../../views/episodes.html"
    };
});
