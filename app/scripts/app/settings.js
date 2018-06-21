angular
  .module("poddr")
  .controller("SettingsController", function (
    $scope,
    RegionService,
    ToastService
  ) {
    var storage = require("electron-json-storage");
    var log = require('electron-log');
    $scope.appVersion = require('electron').remote.app.getVersion();

    RegionService.regions(function (response) {
      $scope.countries = response;
    });

    storage.get("region", function (error, data) {
      if (error) {
        log.error(error);
        $scope.region = "us";
      } else {
        if (data.value) {
          $scope.region = data.value;
        } else {
          $scope.region = "us";
        }
      }
      $scope.$apply();
    });

    storage.get("theme", function (error, data) {
      if (!error && data.value) {
        $scope.color = data.value;
      } else {
        $scope.color = "#ff9900";
      }
      $scope.$apply();
    });

    $scope.openURL = function (url) {
      require("electron").shell.openExternal(url);
    };

    $scope.changeColor = function () {
      var html = document.getElementsByTagName("html")[0];
      html.style.cssText = "--main-color: " + $scope.color;
      storage.set("theme", { value: $scope.color }, function (error) {
        if (error) {
          log.error(error);
          ToastService.errorToast("Couldn't change color.");
        }
      });
    };

    $scope.setRegion = function () {
      storage.set("region", { value: $scope.region }, function (error) {
        if (error) {
          log.error(error);
          ToastService.errorToast("Couldn't change region.");
        }
      });
    };
  });
