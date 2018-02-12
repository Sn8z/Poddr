angular.module('poddr').controller(
  "SettingsController", function($scope, RegionService, $mdTheming){
    var storage = require('electron-json-storage');

    $scope.countries = RegionService.regions;
    $scope.region = $scope.countries[0];

    $scope.openURL = function(url){
      require('electron').shell.openExternal(url);
    };

    storage.get('region', function(error, data) {
      if (error) throw error;
      if(data.value.length > 0){
        $scope.region = data.value;
      }
      $scope.$apply();
    });

    $scope.setRegion = function(){
      storage.set("region", {value: $scope.region}, function(err){
        if(err) console.log(err);
      })
    };
});
