var app = angular.module('poddr')
  .controller("PoddrController", function($scope, $rootScope, $mdToast, $mdSidenav, $http){
    //preloading modules to cache to speed up first time view of for example search page
    var storage = require('electron-json-storage');
    var itunesSearch = require('itunes-api-search');
    var parsePodcast = require('node-podcast-parser');

    let Mousetrap = require('mousetrap');
    Mousetrap.bind('space', function(e){
      e.preventDefault();
      $rootScope.togglePlay();
    });
    Mousetrap.bind('mod+s', function(e){
      e.preventDefault();
      $rootScope.volumeUp();
    });
    Mousetrap.bind('mod+a', function(e){
      e.preventDefault();
      $rootScope.volumeDown();
    });

    //check if update is available
    $http.get("https://raw.githubusercontent.com/Sn8z/Poddr/master/package.json").then(function(response){
      if(response.data.version != require('electron').remote.app.getVersion()){
        var toast = $mdToast.simple()
          .textContent(response.data.version + " available!")
          .position("top right")
          .hideDelay(10000)
          .action("Update now!")
          .toastClass('md-toast-success')

        $mdToast.show(toast).then(function(response){
          if(response == 'ok'){
            require('electron').shell.openExternal('https://github.com/Sn8z/Poddr/releases');
          }
        });
      }
    });

  $rootScope.toggleSidebar = function(){
    $mdSidenav("right").toggle();
  };
  $scope.toggleSidebar = $rootScope.toggleSidebar;

  //Handle maincontent navigation
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

app.directive('favourites', function(){
  return {
    restrict: 'AE',
    replace: true,
    templateUrl: 'views/favourites.html'
  }
})

app.directive('settings', function(){
  return {
    restrict: 'AE',
    replace: true,
    templateUrl: 'views/settings.html'
  }
})

app.directive('episodes', function () {
    return {
      restrict: 'AE',
      replace: true,
      templateUrl: "views/episodes.html"
    };
});
