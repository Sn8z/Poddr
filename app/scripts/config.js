//register module
var app = angular.module("poddr", ["ngMaterial", "ngAnimate"]);

app.config(["$mdThemingProvider", configure]);

function configure($mdThemingProvider) {
  $mdThemingProvider.theme("default").dark();
}

app.filter("secondsToHHmmss", function($filter) {
  return function(seconds) {
    return $filter("date")(new Date(0, 0, 0).setSeconds(seconds), "HH:mm:ss");
  };
});

app.filter("itunesPodcastCover", function() {
  return function(podcastCover) {
    return podcastCover.replace("60x60", "250x250");
  };
});

function ToastService($mdToast) {
  this.successToast = function(text) {
    $mdToast.show(
      $mdToast
        .simple()
        .textContent(text)
        .position("top right")
        .hideDelay(3000)
        .toastClass("md-toast-success")
    );
  };

  this.errorToast = function(text) {
    $mdToast.show(
      $mdToast
        .simple()
        .textContent(text)
        .position("top right")
        .hideDelay(3000)
        .toastClass("md-toast-error")
    );
  };

  this.confirmToast = function(text, callback) {
    var toast = $mdToast
      .simple()
      .textContent("Are you sure?")
      .position("top right")
      .hideDelay(10000)
      .action("Remove")
      .toastClass("md-toast-error");

    $mdToast.show(toast).then(function(response) {
      if (response == "ok") {
        callback(true);
      } else {
        callback(false);
      }
    });
  };
}
app.service("ToastService", ToastService);

//Service to handle global player events & variables
function PlayerService() {
  this.currentlyPlaying = "No title";
  this.podcastDuration = 0;
  this.atTime = 0;
  this.albumCover = "";
  this.podcastID = 0;
}
app.service("PlayerService", PlayerService);

//Favourite
function FavouriteService(ToastService) {
  var storage = require("electron-json-storage");
  this.favourite = function(id, img, title, artist) {
    storage.set(
      id,
      {
        id: id,
        title: title,
        img: img,
        artist: artist,
        dateAdded: Date.now()
      },
      function(err) {
        if (err) {
          console.log(err);
          ToastService.errorToast("Something went wrong");
        } else {
          ToastService.successToast("You now follow " + artist);
        }
      }
    );
  };
}
app.service("FavouriteService", FavouriteService);

//regions service
function RegionService($http, ToastService) {
  var countries = [];
  var countriesFallback = [
    { iso: "de", name: "Germany" },
    { iso: "es", name: "Spain" },
    { iso: "fr", name: "France" },
    { iso: "gb", name: "Great Britain" },
    { iso: "kr", name: "Korea" },
    { iso: "se", name: "Sweden" },
    { iso: "us", name: "Usa" }
  ];
  this.regions = function(callback) {
    $http
      .get("https://api.music.apple.com/v1/storefronts", { cache: true })
      .then(
        function successCallback(response) {
          response.data.data.forEach(function(obj) {
            countries.push({ iso: obj.id, name: obj.attributes.name });
          });
          callback(countries);
        },
        function errorCallback(response) {
          callback(countriesFallback);
        }
      );
  };
}
app.service("RegionService", RegionService);

//genre service
function GenreService() {
  this.genres = [
    { id: 26, genre: "All" },
    { id: 1301, genre: "Arts" },
    { id: 1303, genre: "Comedy" },
    { id: 1304, genre: "Education" },
    { id: 1305, genre: "Kids & Family" },
    { id: 1307, genre: "Health" },
    { id: 1309, genre: "TV & Film" },
    { id: 1310, genre: "Music" },
    { id: 1311, genre: "News & Politics" },
    { id: 1314, genre: "Religion & Spiritiuality" },
    { id: 1315, genre: "Science & Medicine" },
    { id: 1316, genre: "Sports & Recreation" },
    { id: 1307, genre: "Health" },
    { id: 1318, genre: "Technology" },
    { id: 1321, genre: "Business" },
    { id: 1323, genre: "Games & Hobbies" },
    { id: 1324, genre: "Society & Culture" },
    { id: 1325, genre: "Government & Organizations" }
  ];
}
app.service("GenreService", GenreService);
