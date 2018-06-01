//register module
var app = angular.module("poddr", ["ngMaterial", "ngAnimate"]);

app.config(["$mdThemingProvider", configure]);

function configure($mdThemingProvider) {
  $mdThemingProvider.theme("default").dark();
}

app.filter("secondsToHHmmss", function ($filter) {
  return function (seconds) {
    return $filter("date")(new Date(0, 0, 0).setSeconds(seconds), "HH:mm:ss");
  };
});

app.filter("itunesPodcastCover", function () {
  return function (podcastCover) {
    return podcastCover.replace("60x60", "250x250");
  };
});

app.filter("episodeDesc", function () {
  return function (text) {
    return text ? String(text).replace(/<[^>]+>/gm, '') : 'No description available';
  };
});

function ToastService($mdToast) {
  this.successToast = function (text) {
    $mdToast.show(
      $mdToast
        .simple()
        .textContent(text)
        .position("top right")
        .hideDelay(3000)
        .toastClass("md-toast-success")
    );
  };

  this.errorToast = function (text) {
    $mdToast.show(
      $mdToast
        .simple()
        .textContent(text)
        .position("top right")
        .hideDelay(10000)
        .toastClass("md-toast-error")
    );
  };

  this.confirmToast = function (text, callback) {
    var toast = $mdToast
      .simple()
      .textContent("Are you sure?")
      .position("top right")
      .hideDelay(10000)
      .action("Remove")
      .toastClass("md-toast-error");

    $mdToast.show(toast).then(function (response) {
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
  this.podcastDuration = 0;
  this.atTime = 0;

  this.currentlyPlaying = "No title";
  this.podcastArtist = "";
  this.podcastCover = "";
  this.episodeCover = "";
  this.podcastDescription = "";
  this.podcastID = "0";

  this.latestSeenArtist = "";
  this.latestSeenID = "0";
  this.latestSeenCover = "";
}
app.service("PlayerService", PlayerService);

//Favourite
function FavouriteService(ToastService) {
  var storage = require("electron-json-storage");
  this.favourite = function (id, img, title, artist) {
    storage.set(
      id,
      {
        id: id,
        title: title,
        img: img,
        artist: artist,
        dateAdded: Date.now()
      },
      function (err) {
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
  const fs = require("fs");
  var countries = [];
  this.regions = function (callback) {
    //Load local JSON with iTunes storefronts
    fs.readFile(__dirname + "/scripts/storefronts.json", function (
      err,
      response
    ) {
      if (err) {
        console.log(err);
        ToastService.errorToast("Couldn't load storefronts");
      } else {
        JSON.parse(response).data.forEach(function (obj) {
          countries.push({ iso: obj.id, name: obj.attributes.name });
        });
      }
    });
    callback(countries);
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
