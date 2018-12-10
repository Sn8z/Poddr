angular
  .module("poddr")
  .controller("SettingsController", function (
    $scope,
    RegionService,
    ToastService
  ) {
    var storage = require("electron-json-storage");
    var log = require("electron-log");
    var app = require("electron").remote.app;
    $scope.appVersion = app.getVersion();
    $scope.appStorage = storage.getDataPath();
    $scope.electronVersion = process.versions.electron;
    $scope.modKey = process.platform == "darwin" ? "Cmd" : "Ctrl";

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
      $scope.$digest();
    });

    storage.get("layout", function (error, data) {
      if (error) {
        log.error(error);
        $scope.layout = "grid";
      } else {
        if (data.value) {
          $scope.layout = data.value;
        } else {
          $scope.layout = "grid";
        }
      }
      $scope.$digest();
    });

    function changeColor(color) {
      var html = document.getElementsByTagName("html")[0];
      html.style.cssText = "--main-color: " + color;
      storage.set("theme", { value: color }, function (error) {
        if (error) {
          log.error(error);
          ToastService.errorToast("Couldn't change color to " + color);
        } else {
          log.info("Color set to " + color);
        }
      });
    }

    const pickr = Pickr.create({
      el: '.clr-pickr',
      default: 'fff',
      defaultRepresentation: 'HEX',
      components: {
        preview: true,
        opacity: false,
        hue: true,
        interaction: {
          input: true,
          save: true
        }
      },
      strings: {
        save: 'Set color'
      },
      onSave(hsva) {
        changeColor(hsva.toHEX().toString());
      }
    });

    storage.get("theme", function (error, data) {
      if (!error && data.value) {
        pickr.setColor(data.value);
      } else {
        pickr.setColor("#ff9900");
      }
    });

    $scope.openURL = function (url) {
      require("electron").shell.openExternal(url);
    };

    $scope.setRegion = function () {
      storage.set("region", { value: $scope.region }, function (error) {
        if (error) {
          log.error(error);
          ToastService.errorToast("Couldn't change region.");
        }
      });
    };

    $scope.setLayout = function () {
      storage.set("layout", { value: $scope.layout }, function (error) {
        if (error) {
          log.error(error);
          ToastService.errorToast("Couldn't set default layout.");
        }
      });
    };
  });
