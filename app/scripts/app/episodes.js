angular
	.module("poddr")
	.controller("EpisodesController", function (
		$scope,
		$rootScope,
		$http,
		$filter,
		$mdSidenav,
		$q,
		ToastService,
		PlayerService,
		PrevPlayedFactory
	) {
		var parsePodcast = require("node-podcast-parser");
		var log = require("electron-log");

		//Calculating number of episodes to load by default based on application outer height, 55px is min height of a episode element.
		const EPISODE_BASE_LIMIT = Math.floor(window.outerHeight / 55);
		$scope.limit = EPISODE_BASE_LIMIT;
		$scope.query = "";

		$scope.prevPlayedEpisodes = PrevPlayedFactory.getGUIDs();

		$scope.podcastCover = "";
		$scope.isLoading = false;
		$scope.playPodcast = $rootScope.playPodcast;
		$scope.episodes = [];
		var allEpisodes = [];

		var closeSidenav = function () {
			$mdSidenav("right").close();
		}
		$scope.closeSidenav = closeSidenav;

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

		var openEpisodes = function (rss, title, cover) {
			log.info("OPENING EPISODES");
			resetEpisodes(title, cover);
			$scope.isLoading = true;
			$mdSidenav("right").open().then(function () {
				fetchEpisodes(rss, title);
			});
		};
		$rootScope.openEpisodes = openEpisodes;

		var openEpisodesWithID = function (id, title, cover) {
			resetEpisodes(title, cover);
			$scope.isLoading = true;
			$mdSidenav("right").open().then(function () {
				getRssFeed(id).then(function (rss) {
					fetchEpisodes(rss, title);
				});
			});
		};
		$rootScope.openEpisodesWithID = openEpisodesWithID;

		var resetEpisodes = function (title, cover) {
			PlayerService.latestSeenTitle = title;
			PlayerService.latestSeenCover = cover;
			PlayerService.latestSeenRSS = "";
			$scope.podcastCover = cover;
			$scope.query = "";
			$scope.episodeTitle = PlayerService.latestSeenTitle;
			$scope.episodes = [];
			allEpisodes = [];
		};

		var fetchEpisodes = function (rss, title) {
			log.info("Fetching episodes for " + title + "...");
			log.info("Getting podcastfeed: " + rss);
			PlayerService.latestSeenRSS = rss;
			$http.get(rss, { timeout: 20000 })
				.then(function successCallback(response) {
					log.info("Successfully fetched podcastfeed.");
					log.info("Parsing podcastfeed...");
					parsePodcast(response.data, function (error, data) {
						if (error) {
							log.error(error);
							ToastService.errorToast("Parsing podcastfeed failed.");
						} else {
							$scope.episodes = data.episodes;
							allEpisodes = angular.copy(data.episodes);
							log.info("Parsed " + $scope.episodes.length + " episodes.");
						}
					});
				}, function errorCallback(error) {
					log.error(error);
					ToastService.errorToast("Failed to get podcast RSS feed.");
				}).finally(function () {
					log.info("Done with podcastfeed.");
					$scope.isLoading = false;
				});
		};
		$rootScope.fetchEpisodes = fetchEpisodes;

		//Check if episode is already played
		$scope.isPlayed = function (id) {
			return $scope.prevPlayedEpisodes["prevGUIDs"] ? $scope.prevPlayedEpisodes["prevGUIDs"].indexOf(id) !== -1 : false;
		};

		//Filter episodes
		$scope.filterEpisodes = function () {
			$scope.episodes = $filter("filter")(allEpisodes, $scope.query);
		};

		//Toggle order based on publish date
		$scope.toggleOrder = true;
		$scope.toggleOrderBy = function () {
			$scope.toggleOrder = !$scope.toggleOrder;
			if ($scope.toggleOrder) {
				$scope.episodes = $filter("orderBy")($scope.episodes, "-published");
			} else {
				$scope.episodes = $filter("orderBy")($scope.episodes, "published");
			}
		};

		//Fetch and render more episodes as the user scrolls the episode list
		var episodeNav = document.getElementById("right-sidenav");
		var loadMoreEpisodes = function () {
			//check if scroll is at bottom & if there is more episodes to load
			if (
				episodeNav.scrollTop ===
				episodeNav.scrollHeight - episodeNav.offsetHeight &&
				$scope.limit < $scope.episodes.length
			) {
				$scope.limit += 10;
				$scope.$digest();
			}
		};

		//Listen for the scroll event of the episode list
		episodeNav.addEventListener("scroll", loadMoreEpisodes);

		//Check if we need to load more episodes when the window size changes
		window.addEventListener("resize", loadMoreEpisodes);
	});
