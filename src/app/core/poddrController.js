var app = angular
	.module("poddr")
	.controller("PoddrController", function (
		$scope,
		$rootScope,
		$mdToast,
		$mdSidenav,
		$http,
		$window,
		$timeout,
		PlayerService,
		PrevPlayedService,
		FavouriteService
	) {
		//preloading modules to cache to speed up first time view of for example search page
		const Store = require("electron-store");
		const store = new Store();
		const fs = require("fs");
		var log = require("electron-log");
		var parsePodcast = require("node-podcast-parser");
		var app = require("electron").remote.app;
		log.info("Settings are stored at " + app.getPath('userData'));

		$scope.playerService = PlayerService;

		Mousetrap.bind("space", function (e) {
			e.preventDefault();
			$rootScope.togglePlay();
		});
		Mousetrap.bindGlobal("escape", function (e) {
			document.activeElement.blur();
		});
		Mousetrap.bindGlobal("mod+up", function (e) {
			e.preventDefault();
			$rootScope.changeVolume(0.005);
		});
		Mousetrap.bindGlobal("mod+down", function (e) {
			e.preventDefault();
			$rootScope.changeVolume(-0.005);
		});
		Mousetrap.bindGlobal("mod+left", function (e) {
			e.preventDefault();
			$rootScope.changePlayerTime(-1);
		});
		Mousetrap.bindGlobal("mod+right", function (e) {
			e.preventDefault();
			$rootScope.changePlayerTime(1);
		});
		Mousetrap.bindGlobal("mod+1", function (e) {
			e.preventDefault();
			changeView("podcasts");
			$scope.$digest();
		});
		Mousetrap.bindGlobal(["mod+2", "mod+f", "mod+l"], function (e) {
			e.preventDefault();
			changeView("search");
			$scope.$digest();
		});
		Mousetrap.bindGlobal("mod+3", function (e) {
			e.preventDefault();
			changeView("favourites");
			$scope.$digest();
		});
		Mousetrap.bindGlobal("mod+4", function (e) {
			e.preventDefault();
			changeView("settings");
			$scope.$digest();
		});
		Mousetrap.bindGlobal("mod+e", function (e) {
			e.preventDefault();
			toggleSidebar();
		});

		$scope.init = function () {
			var color = store.get("color", "#FF9900");
			var html = document.getElementsByTagName("html")[0];
			html.style.cssText = "--main-color: " + color;
			log.info("Loaded CSS color variable (" + color + ").");
		};

		var getOldColor = function () {
			try {
				var themeFilePath = app.getPath('userData') + "/storage/theme.json";
				var themeFile = fs.readFileSync(themeFilePath);
				var color = JSON.parse(themeFile).value;
				if (color) store.set("color", color);
				var html = document.getElementsByTagName("html")[0];
				html.style.cssText = "--main-color: " + color;
				log.info("Done getting color " + color + " from old settings.");
			} catch (error) {
				log.error(error);
			}
		};

		var getOldRegion = function () {
			try {
				var region = JSON.parse(fs.readFileSync(app.getPath('userData') + "/storage/region.json")).value;
				if (region) store.set("region", region);
				log.info("Done getting region " + region + " from old settings.");
			} catch (error) {
				log.error(error);
			}
		};

		var getOldPlayedEpisodes = function () {
			try {
				var playedEpisodes = JSON.parse(fs.readFileSync(app.getPath('userData') + "/storage/prevPlayed.json")).guids;
				playedEpisodes.forEach(function (guid) {
					PrevPlayedService.setPrevPlayed(guid);
					log.info("Added " + guid + " from old guids.");
				});
				log.info("Done importing old played episodes.");
			} catch (error) {
				log.error(error);
			}
		};

		var getOldFavs = function () {
			try {
				log.info("Getting old favourites.");
				var files = fs.readdirSync(app.getPath('userData') + "/storage");
				files.forEach(function (file) {
					if (/^([0-9]+.json)$/.test(file)) {
						var data = fs.readFileSync(app.getPath('userData') + "/storage/" + file);
						data = JSON.parse(data);
						FavouriteService.favouriteItunesId(data.id, data.img, data.title);
						log.info("Added iTunes ID " + file + " from old favourites.");
					}
				});
			} catch (error) {
				log.error(error);
			}
		};

		var removeOldStorage = function () {
			try {
				log.info("Removing old storage folder.");
				var files = fs.readdirSync(app.getPath('userData') + "/storage");
				files.forEach(function (file) {
					fs.unlinkSync(app.getPath('userData') + "/storage/" + file);
				});
				fs.rmdirSync(app.getPath('userData') + "/storage");
				log.info("Done Removing old storage folder.");
			} catch (error) {
				log.error(error);
			}
		};

		//Checks if there is old settings/favs and moves them to Poddr v1.1.0+ format
		var checkOldStorage = function () {
			var storageFolderPath = app.getPath('userData') + "/storage";
			log.info("Checking for old settings in " + storageFolderPath);
			if (fs.existsSync(storageFolderPath)) {
				log.info("Getting old settings from " + storageFolderPath);
				getOldColor();
				getOldRegion();
				getOldPlayedEpisodes();
				getOldFavs();
				removeOldStorage();
				log.info("Done importing old settings and cleaning up.");
			} else {
				log.info("Nothing old to import.");
			}
		};
		checkOldStorage();

		//check if update is available
		var checkUpdates = function () {
			log.info("Checking for updates...");
			$http
				.get("https://raw.githubusercontent.com/Sn8z/Poddr/master/package.json", { timeout: 10000 })
				.then(function (response) {
					if (
						response.data.version != require("electron").remote.app.getVersion()
					) {
						var toast = $mdToast
							.simple()
							.textContent(response.data.version + " available!")
							.position("top right")
							.hideDelay(10000)
							.action("Update now!")
							.toastClass("md-toast-success");
						$mdToast.show(toast).then(function (response) {
							if (response == "ok") {
								require("electron").shell.openExternal(
									"https://github.com/Sn8z/Poddr/releases"
								);
							}
						});
						log.info("Update available.");
					}
				});
		};

		$timeout(function () {
			checkUpdates();
		}, 2000);

		function toggleSidebar() {
			$mdSidenav("right").toggle();
		}
		$rootScope.toggleSidebar = toggleSidebar;
		$scope.toggleSidebar = $rootScope.toggleSidebar;

		//Handle maincontent navigation
		$scope.mainContent = "podcasts";
		function changeView(view) {
			if (view == $scope.mainContent && view == "search") {
				var search = $window.document.getElementById("search-input");
				search.value = "";
				search.focus();
			}
			$scope.mainContent = view;
			log.info("Changed view to " + view);
		}
		$scope.changeView = changeView;

		// Add class to body when the mouse is being used
		// These functions work together with CSS :focus on different elements
		document.body.addEventListener('mousedown', function () {
			document.body.classList.add('using-mouse');
		});
		document.body.addEventListener('keydown', function () {
			document.body.classList.remove('using-mouse');
		});
	});

app.directive("podcasts", function () {
	return {
		restrict: "AE",
		replace: true,
		templateUrl: "../views/toplist/toplist.html"
	};
});

app.directive("search", function () {
	return {
		restrict: "AE",
		replace: true,
		templateUrl: "../views/search/search.html"
	};
});

app.directive("favourites", function () {
	return {
		restrict: "AE",
		replace: true,
		templateUrl: "../views/favourites/favourites.html"
	};
});

app.directive("settings", function () {
	return {
		restrict: "AE",
		replace: true,
		templateUrl: "../views/settings/settings.html"
	};
});

app.directive("episodes", function () {
	return {
		restrict: "AE",
		replace: true,
		templateUrl: "../views/episodes/episodes.html"
	};
});
