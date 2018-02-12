//register module
var app = angular.module('poddr', ['ngMaterial', 'ngAnimate']);

app.config(['$mdThemingProvider', configure]);

function configure($mdThemingProvider){
  $mdThemingProvider.theme('dark-orange')
  .primaryPalette('orange')
  .accentPalette('orange')
  .dark();
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
    this.currentlyPlaying = "No title";
    this.podcastDuration = 0;
    this.atTime = 0;
    this.albumCover = "";
    this.podcastID = 0;
}
app.service('PlayerService', PlayerService);

//regions service
function RegionService(){
  this.regions = [
    { "iso": "de", "name": "Germany" },
    { "iso": "es", "name": "Spain" },
    { "iso": "fr", "name": "France" },
    { "iso": "gb", "name": "Great Britain" },
    { "iso": "kr", "name": "Korea" },
    { "iso": "se", "name": "Sweden"},
    { "iso": "us", "name": "Usa" }
  ];
}
app.service('RegionService', RegionService);

//genre service
function GenreService() {
  this.genres = [
    { "id": 26, "genre": "All" },
    { "id": 1301, "genre": "Arts" },
    { "id": 1303, "genre": "Comedy" },
    { "id": 1304, "genre": "Education" },
    { "id": 1305, "genre": "Kids & Family" },
    { "id": 1307, "genre": "Health" },
    { "id": 1309, "genre": "TV & Film" },
    { "id": 1310, "genre": "Music" },
    { "id": 1311, "genre": "News & Politics" },
    { "id": 1314, "genre": "Religion & Spiritiuality" },
    { "id": 1315, "genre": "Science & Medicine" },
    { "id": 1316, "genre": "Sports & Recreation" },
    { "id": 1307, "genre": "Health" },
    { "id": 1318, "genre": "Technology" },
    { "id": 1321, "genre": "Business" },
    { "id": 1323, "genre": "Games & Hobbies" },
    { "id": 1324, "genre": "Society & Culture" },
    { "id": 1325, "genre": "Government & Organizations" }
  ];
}
app.service('GenreService', GenreService);
