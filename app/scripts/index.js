//register module
var app = angular.module('poddr', ['ngMaterial']);

app.config(['$mdThemingProvider', configure]);

function configure($mdThemingProvider){
  $mdThemingProvider.theme('dark-orange')
  .primaryPalette('orange')
  .accentPalette('orange')
  .dark()
  $mdThemingProvider.setDefaultTheme('dark-orange');
}

app.filter('secondsToHHmmss', function($filter) {
    return function(seconds) {
        return $filter('date')(new Date(0, 0, 0).setSeconds(seconds), 'HH:mm:ss');
    };
});

app.filter('tagToCapitalize', function($filter) {
    return function(tag) {
      if(tag != null){
        return tag.toUpperCase().replace(/-/g, " & ");
      }
    };
});

app.filter('pagination', function(){
  return function(input, start){
   start = +start;
   return input.slice(start);
  };
})

//Service to handle global player events & variables
function PlayerService() {
    this.currentlyPlaying = "";
    this.podcastDuration = 0;
    this.atTime = 0;
    this.albumCover;
}
app.service('PlayerService', PlayerService);

//regions service
function RegionService(){
  this.regions = ["us", "gb", "se", "fr", "es"];
}
app.service('RegionService', RegionService);
