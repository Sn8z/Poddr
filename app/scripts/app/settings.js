angular.module('poddr').controller(
  "SettingsController", function($scope, RegionService, $mdTheming){
    var storage = require('electron-json-storage');

    $scope.countries = RegionService.regions;
    $scope.region = $scope.countries[0];

    storage.get('region', function (error, data) {
      if (error) throw error;
      if (data.value.length > 0) {
        $scope.region = data.value;
      }
      $scope.$apply();
    });

    storage.get('theme', function (error, data) {
      if (!error && data.value){
        $scope.color = data.value;
      } else {
        $scope.color = "#ff9900";        
      }
      $scope.$apply();
    });

    $scope.openURL = function(url){
      require('electron').shell.openExternal(url);
    };


    $scope.changeColor = function(){
      var html = document.getElementsByTagName('html')[0];
      html.style.cssText = "--main-color: " + $scope.color;
      storage.set("theme", { value: $scope.color }, function (err) {
        if (err) console.log(err);
      });
    }

    $scope.setRegion = function(){
      storage.set("region", {value: $scope.region}, function(err){
        if(err) console.log(err);
      });
    };
});
