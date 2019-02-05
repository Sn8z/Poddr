//register module
var app = angular.module("poddr", ["ngMaterial", "ngAnimate"]);

app.config(["$mdThemingProvider", configureTheme]);

function configureTheme($mdThemingProvider) {
	$mdThemingProvider.theme("default").dark();
}

app.filter("secondsToHHmmss", function ($filter) {
	return function (seconds) {
		return seconds ? $filter("date")(new Date(0, 0, 0).setSeconds(seconds), "HH:mm:ss") : "00:00:00";
	};
});

app.filter("itunesPodcastCover", function () {
	return function (podcastCover) {
		return podcastCover.replace("60x60", "250x250");
	};
});

app.filter("episodeDesc", function () {
	return function (text) {
		return text ? String(text).replace(/<[^>]+>/gm, "") : "No description available";
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
	const Store = require("electron-store");
	const store = new Store();
	var log = require("electron-log");

	this.podcastDuration = 0;
	this.atTime = 0;

	this.podcastTitle = "";
	this.podcastEpisodeTitle = "No title";
	this.podcastCover = "";
	this.episodeCover = "";
	this.podcastDescription = "";
	this.podcastRSS = "";
	this.podcastURL = "";
	this.podcastGUID = "";

	this.latestSeenTitle = "";
	this.latestSeenRSS = "";
	this.latestSeenCover = "";

	this.saveState = function () {
		store.set("playerState", {
			podcastURL: this.podcastURL,
			podcastTitle: this.podcastTitle,
			podcastEpisodeTitle: this.podcastEpisodeTitle,
			podcastCover: this.podcastCover,
			episodeCover: this.episodeCover,
			podcastRSS: this.podcastRSS,
			podcastDescription: this.podcastDescription,
			podcastGUID: this.podcastGUID
		});
		log.info("Saved playerstate!");
	};
}
app.service("PlayerService", PlayerService);

//Favourite Factory
function FavouriteFactory() {
	const Store = require("electron-store");
	const favStore = new Store({ name: "favourites" });
	var log = require("electron-log");

	var favourites = {
		keys: [],
		titles: [],
		all: []
	};

	var getFavouriteKeys = function () {
		return Object.keys(favStore.store);
	};

	var getFavouriteTitles = function () {
		return Object.values(favStore.store).map(function (x) { return x.title; });
	};

	var getAllFavourites = function () {
		return favStore.store;
	};

	favourites.titles = getFavouriteTitles();
	favourites.keys = getFavouriteKeys();
	favourites.all = getAllFavourites();

	return {
		getList: function () {
			return favourites;
		},
		updateList: function () {
			favourites.titles = getFavouriteTitles();
			favourites.keys = getFavouriteKeys();
			favourites.all = getAllFavourites();
		}
	};
}
app.factory("FavouriteFactory", FavouriteFactory);

//Favourite Service
function FavouriteService($q, $http, ToastService, FavouriteFactory) {
	const Store = require("electron-store");
	const favStore = new Store({ name: "favourites" });
	var log = require("electron-log");

	var setFavourite = function (rss, img, title) {
		favStore.set(rss.replace(/\./g, '\\.'), {
			rss: rss,
			title: title,
			img: img,
			dateAdded: Date.now()
		});
		FavouriteFactory.updateList();
		log.info("Added " + title + " to favourites.");
		ToastService.successToast("You now follow " + title);
	};

	this.favourite = setFavourite;

	this.favouriteItunesId = function (id, img, title) {
		var getRssFeed = function (id) {
			var q = $q.defer();
			log.info("Looking up iTunes id: " + id);
			$http.get("https://itunes.apple.com/lookup?id=" + id, { timeout: 20000 })
				.then(function successCallback(response) {
					log.info("Found RSS feed: " + response.data.results[0].feedUrl);
					q.resolve(response.data.results[0].feedUrl);
				}, function errorCallback(error) {
					log.error(error);
					ToastService.errorToast("Failed to get podcast RSS feed.");
					q.reject(error);
				}).finally(function () {
					log.info("Done checking iTunes id.");
				});
			return q.promise;
		};

		getRssFeed(id).then(function (rss) {
			setFavourite(rss, img, title);
		});
	};

	this.removeFavourite = function (rss) {
		ToastService.confirmToast("Are you sure?", function (response) {
			if (response) {
				favStore.delete(rss.replace(/\./g, '\\.'));
				FavouriteFactory.updateList();
				log.info("RSS feed: " + rss + " removed from favourites.");
				ToastService.successToast("Removed podcast from favourites.");
			}
		});
	};
}
app.service("FavouriteService", FavouriteService);

//Previously Played Factory
function PrevPlayedFactory() {
	const Store = require("electron-store");
	const prevPlayedStore = new Store({ name: "previouslyPlayed" });
	var log = require("electron-log");

	var prevPlayedEpisodes = {
		prevGUIDs: []
	};

	var getPrevPlayedEpisodes = function () {
		return Object.keys(prevPlayedStore.store);
	};

	prevPlayedEpisodes.prevGUIDs = getPrevPlayedEpisodes();

	return {
		getGUIDs: function () {
			return prevPlayedEpisodes;
		},
		updateGUIDs: function () {
			prevPlayedEpisodes.prevGUIDs = getPrevPlayedEpisodes();
		}
	};
}
app.factory("PrevPlayedFactory", PrevPlayedFactory);

//Previously Played service
function PrevPlayedService(PrevPlayedFactory) {
	const Store = require("electron-store");
	const prevPlayedStore = new Store({ name: "previouslyPlayed" });
	var log = require("electron-log");

	this.setPrevPlayed = function (guid) {
		//regexp disables dot notation for electron-store, keep until fixed
		prevPlayedStore.set(guid.replace(/\./g, '\\.'), Date.now());
		PrevPlayedFactory.updateGUIDs();
		log.info("Added " + guid + " to previously played episodes.");
	};

	this.removePrevPlayed = function (guid) {
		prevPlayedStore.delete(guid);
		PrevPlayedFactory.updateGUIDs();
		log.info("Removed " + guid + " from previously played episodes.");
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
			callback(countries);
		});
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
