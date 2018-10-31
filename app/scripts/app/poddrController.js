var app = angular
  .module("poddr")
  .controller("PoddrController", function(
    $scope,
    $rootScope,
    $mdToast,
    $mdSidenav,
    $http,
    $window,
    $timeout,
    PlayerService
  ) {
    //preloading modules to cache to speed up first time view of for example search page
    var storage = require("electron-json-storage");
    var log = require("electron-log");
    var parsePodcast = require("node-podcast-parser");
    log.info("Settings are stored at " + storage.getDataPath());

    $scope.playerService = PlayerService;

    Mousetrap.bind("space", function(e) {
      e.preventDefault();
      $rootScope.togglePlay();
    });
    Mousetrap.bindGlobal("mod+up", function(e) {
      e.preventDefault();
      $rootScope.volumeUp();
    });
    Mousetrap.bindGlobal("mod+down", function(e) {
      e.preventDefault();
      $rootScope.volumeDown();
    });
    Mousetrap.bindGlobal("mod+left", function(e) {
      e.preventDefault();
      $rootScope.rewind(1);
    });
    Mousetrap.bindGlobal("mod+right", function(e) {
      e.preventDefault();
      $rootScope.forward(1);
    });
    Mousetrap.bindGlobal("mod+1", function(e) {
      e.preventDefault();
      changeView("podcasts");
      $scope.$digest();
    });
    Mousetrap.bindGlobal(["mod+2", "mod+f", "mod+l"], function(e) {
      e.preventDefault();
      changeView("search");
      $scope.$digest();
    });
    Mousetrap.bindGlobal("mod+3", function(e) {
      e.preventDefault();
      changeView("favourites");
      $scope.$digest();
    });
    Mousetrap.bindGlobal("mod+4", function(e) {
      e.preventDefault();
      changeView("settings");
      $scope.$digest();
    });
    Mousetrap.bindGlobal("mod+e", function(e) {
      e.preventDefault();
      toggleSidebar();
    });

    $scope.init = function() {
      storage.get("theme", function(error, data) {
        var color = "#ff9900";
        if (!error && data.value) {
          color = data.value;
        }
        var html = document.getElementsByTagName("html")[0];
        html.style.cssText = "--main-color: " + color;
        log.info("Loaded CSS color variable.");
      });
    };

    //check if update is available
    var checkUpdates = function() {
      $http
        .get("https://raw.githubusercontent.com/Sn8z/Poddr/master/package.json", {timeout: 10000})
        .then(function(response) {
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
            $mdToast.show(toast).then(function(response) {
              if (response == "ok") {
                require("electron").shell.openExternal(
                  "https://github.com/Sn8z/Poddr/releases"
                );
              }
            });
            log.info("Update available.");
          }
        });
    };

    $timeout(function() {
      checkUpdates();
    }, 2000);

    function toggleSidebar() {
      $mdSidenav("right").toggle();
    }
    $rootScope.toggleSidebar = toggleSidebar;
    $scope.toggleSidebar = $rootScope.toggleSidebar;

    //Handle maincontent navigation
    $scope.mainContent = "podcasts";
    function changeView(view) {
      if (view == $scope.mainContent && view == "search") {
        var search = $window.document.getElementById("search-input");
        search.value = "";
        search.focus();
      }
      $scope.mainContent = view;
      log.info("Changed view to " + view);
    }
    $scope.changeView = changeView;

    // Add class to body when the mouse is being used
    // These functions work together with CSS :focus on different elements
    document.body.addEventListener('mousedown', function() {
      document.body.classList.add('using-mouse');
    });
    document.body.addEventListener('keydown', function() {
      document.body.classList.remove('using-mouse');
    });
  });

app.directive("podcasts", function() {
  return {
    restrict: "AE",
    replace: true,
    templateUrl: "views/podcasts.html"
  };
});

app.directive("search", function() {
  return {
    restrict: "AE",
    replace: true,
    templateUrl: "views/search.html"
  };
});

app.directive("favourites", function() {
  return {
    restrict: "AE",
    replace: true,
    templateUrl: "views/favourites.html"
  };
});

app.directive("settings", function() {
  return {
    restrict: "AE",
    replace: true,
    templateUrl: "views/settings.html"
  };
});

app.directive("episodes", function() {
  return {
    restrict: "AE",
    replace: true,
    templateUrl: "views/episodes.html"
  };
});
