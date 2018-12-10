//register module
var app = angular.module("poddr", ["ngMaterial", "ngAnimate"]);

app.config(["$mdThemingProvider", configureTheme]);

function configureTheme($mdThemingProvider) {
  $mdThemingProvider.theme("default").dark();
}

app.filter("secondsToHHmmss", function ($filter) {
  return function (seconds) {
    return seconds
      ? $filter("date")(new Date(0, 0, 0).setSeconds(seconds), "HH:mm:ss")
      : "00:00:00";
  };
});

app.filter("itunesPodcastCover", function () {
  return function (podcastCover) {
    return podcastCover.replace("60x60", "250x250");
  };
});

app.filter("episodeDesc", function () {
  return function (text) {
    return text
      ? String(text).replace(/<[^>]+>/gm, "")
      : "No description available";
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
  var storage = require("electron-json-storage");
  var log = require("electron-log");

  this.podcastDuration = 0;
  this.atTime = 0;

  this.currentlyPlaying = "No title";
  this.podcastArtist = "";
  this.podcastCover = "";
  this.episodeCover = "";
  this.podcastDescription = "";
  this.podcastID = "0";
  this.podcastURL = "";
  this.podcastGUID = "";

  this.latestSeenArtist = "";
  this.latestSeenID = "0";
  this.latestSeenCover = "";

  this.saveState = function () {
    storage.set(
      "playerState",
      {
        podcastURL: this.podcastURL,
        podcastTitle: this.currentlyPlaying,
        podcastArtist: this.podcastArtist,
        podcastCover: this.podcastCover,
        episodeCover: this.episodeCover,
        podcastID: this.podcastID,
        podcastDescription: this.podcastDescription,
        podcastGUID: this.podcastGUID
      },
      function (error) {
        if (error) {
          log.error(error);
        } else {
          log.info("Saved playerstate!");
        }
      }
    );
  };
}
app.service("PlayerService", PlayerService);

//Favourite Factory
function FavouriteFactory($q) {
  var storage = require("electron-json-storage");
  var log = require("electron-log");

  var favourites = {
    keys: [],
    all: []
  };

  var getFavouriteKeys = function () {
    const q = $q.defer();
    storage.keys(function (error, keys) {
      if (error) {
        log.error(error);
        return q.reject(err);
      }
      q.resolve(keys);
    });
    return q.promise;
  };

  var getAllFavourites = function () {
    const q = $q.defer();
    storage.getAll(function (error, data) {
      if (error) {
        log.error(error);
        return q.reject(error);
      }
      delete data.volume;
      delete data.region;
      delete data.theme;
      delete data.playerState;
      delete data.prevPlayed;
      delete data.layout;
      q.resolve(data);
    });
    return q.promise;
  };

  getFavouriteKeys().then(function (response) {
    favourites.keys = response;
  });

  getAllFavourites().then(function (response) {
    favourites.all = response;
  });

  return {
    getList: function () {
      return favourites;
    },
    updateList: function () {
      getFavouriteKeys().then(function (response) {
        favourites.keys = response;
      });
      getAllFavourites().then(function (response) {
        favourites.all = response;
      });
    }
  };
}
app.factory("FavouriteFactory", FavouriteFactory);

//Favourite Service
function FavouriteService(ToastService, FavouriteFactory, $q) {
  var storage = require("electron-json-storage");
  var log = require("electron-log");

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
      function (error) {
        if (error) {
          log.error(error);
          ToastService.errorToast("Couldn't add podcast to favourites.");
        } else {
          FavouriteFactory.updateList();
          log.info("Added " + artist + " to favourites.");
          ToastService.successToast("You now follow " + artist);
        }
      }
    );
  };

  this.removeFavourite = function (id) {
    const q = $q.defer();
    ToastService.confirmToast("Are you sure?", function (response) {
      if (response) {
        storage.remove(id, function (error) {
          if (error) {
            log.error(error);
            ToastService.errorToast("Couldn't remove favourite.");
            q.resolve(false);
          } else {
            FavouriteFactory.updateList();
            log.info(id + " removed from favourites.");
            ToastService.successToast("Removed podcast from favourites.");
            q.resolve(true);
          }
        });
      } else {
        q.resolve(false);
      }
    });
    return q.promise;
  };
}
app.service("FavouriteService", FavouriteService);

//Previously Played Factory
function PrevPlayedFactory($q) {
  var storage = require("electron-json-storage");
  var log = require("electron-log");

  var prevPlayedEpisodes = {
    prevGUIDs: []
  };

  var getPrevPlayedEpisodes = function () {
    const q = $q.defer();
    storage.get("prevPlayed", function (error, data) {
      if (error) {
        log.error(error);
        return q.reject(error);
      }
      q.resolve(data);
    });
    return q.promise;
  };

  getPrevPlayedEpisodes().then(function (response) {
    prevPlayedEpisodes.prevGUIDs = response;
  });

  return {
    getGUIDs: function () {
      return prevPlayedEpisodes;
    },
    updateGUIDs: function () {
      getPrevPlayedEpisodes().then(function (response) {
        prevPlayedEpisodes.prevGUIDs = response;
      });
    }
  };
}
app.factory("PrevPlayedFactory", PrevPlayedFactory);

//Previously Played service
function PrevPlayedService(PrevPlayedFactory, $q) {
  var storage = require("electron-json-storage");
  var log = require("electron-log");

  this.setPrevPlayed = function (guid) {
    var prevEpisodes = PrevPlayedFactory.getGUIDs().prevGUIDs;
    if (angular.equals(prevEpisodes, {})) {
      prevEpisodes = [guid];
    } else {
      prevEpisodes["guids"].push(guid);
      prevEpisodes = prevEpisodes["guids"];
      prevEpisodes = Array.from(new Set(prevEpisodes));
    }
    storage.set("prevPlayed", { guids: prevEpisodes }, function (error) {
      if (error) {
        log.error(error);
      } else {
        PrevPlayedFactory.updateGUIDs();
        log.info("Added " + guid + " to previously played episodes.");
      }
    });
  };
}
app.service("PrevPlayedService", PrevPlayedService);

//regions service
function RegionService(ToastService) {
  const fs = require("fs");
  var log = require("electron-log");
  this.regions = function (callback) {
    var countries = [];
    log.info("Fetching storefronts...");
    //Load local JSON with iTunes storefronts
    fs.readFile(__dirname + "/scripts/storefronts.json", function (
      error,
      response
    ) {
      if (error) {
        log.error(error);
        ToastService.errorToast("Couldn't load storefronts.");
      } else {
        JSON.parse(response).data.forEach(function (obj) {
          countries.push({ iso: obj.id, name: obj.attributes.name });
        });
        log.info("Done fetching storefronts.");
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
