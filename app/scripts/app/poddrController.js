var app = angular
  .module("poddr")
  .controller("PoddrController", function (
    $scope,
    $rootScope,
    $mdToast,
    $mdSidenav,
    $http,
    $window,
    PlayerService
  ) {
    //preloading modules to cache to speed up first time view of for example search page
    var storage = require("electron-json-storage");
    var log = require('electron-log');
    var parsePodcast = require("node-podcast-parser");

    $scope.playerService = PlayerService;

    Mousetrap.bind("space", function (e) {
      e.preventDefault();
      $rootScope.togglePlay();
    });
    Mousetrap.bindGlobal("mod+s", function (e) {
      e.preventDefault();
      $rootScope.volumeUp();
    });
    Mousetrap.bindGlobal("mod+a", function (e) {
      e.preventDefault();
      $rootScope.volumeDown();
    });
    Mousetrap.bindGlobal("mod+z", function (e) {
      e.preventDefault();
      $rootScope.rewind();
    });
    Mousetrap.bindGlobal("mod+x", function (e) {
      e.preventDefault();
      $rootScope.forward();
    });

    $scope.init = function () {
      storage.get("theme", function (error, data) {
        var color = "#ff9900";
        if (!error && data.value) {
          color = data.value;
        }
        var html = document.getElementsByTagName("html")[0];
        html.style.cssText = "--main-color: " + color;
        log.info('Loaded CSS color variable.');
      });
    };

    //check if update is available
    $http
      .get("https://raw.githubusercontent.com/Sn8z/Poddr/master/package.json")
      .then(function (response) {
        if (
          response.data.version != require("electron").remote.app.getVersion()
        ) {
          var toast = $mdToast
            .simple()
            .textContent(response.data.version + " available!")
            .position("top right")
            .hideDelay(10000)
            .action("Update now!")
            .toastClass("md-toast-success");
          $mdToast.show(toast).then(function (response) {
            if (response == "ok") {
              require("electron").shell.openExternal(
                "https://github.com/Sn8z/Poddr/releases"
              );
            }
          });
          log.info('Update available.');
        }
      });

    $rootScope.toggleSidebar = function () {
      $mdSidenav("right").toggle();
    };
    $scope.toggleSidebar = $rootScope.toggleSidebar;

    //Handle maincontent navigation
    $scope.mainContent = "podcasts";
    function changeView(view) {
      if (view == $scope.mainContent && view == "search"){
        var search = $window.document.getElementById("search-input");
        search.value = "";
        search.focus();
      }
      $scope.mainContent = view;
      log.info('Changed view to ' + view);
    }
    $scope.changeView = changeView;
  });

app.directive("podcasts", function () {
  return {
    restrict: "AE",
    replace: true,
    templateUrl: "views/podcasts.html"
  };
});

app.directive("search", function () {
  return {
    restrict: "AE",
    replace: true,
    templateUrl: "views/search.html"
  };
});

app.directive("favourites", function () {
  return {
    restrict: "AE",
    replace: true,
    templateUrl: "views/favourites.html"
  };
});

app.directive("settings", function () {
  return {
    restrict: "AE",
    replace: true,
    templateUrl: "views/settings.html"
  };
});

app.directive("episodes", function () {
  return {
    restrict: "AE",
    replace: true,
    templateUrl: "views/episodes.html"
  };
});
