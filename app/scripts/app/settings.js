angular
	.module("poddr")
	.controller("SettingsController", function (
		$scope,
		RegionService,
		$timeout
	) {
		const Store = require("electron-store");
		const store = new Store();
		var log = require("electron-log");
		var app = require("electron").remote.app;

		$scope.appVersion = app.getVersion();
		$scope.appStorage = app.getPath('userData');
		$scope.electronVersion = process.versions.electron;
		$scope.modKey = process.platform == "darwin" ? "Cmd" : "Ctrl";

		$scope.region = store.get("region", "us");
		$scope.layout = store.get("layout", "grid");
		$scope.countries = [];
		RegionService.regions(function (data) {
			$scope.countries = data;
			$scope.$digest();
		});

		var changeColor = function (color) {
			var html = document.getElementsByTagName("html")[0];
			html.style.cssText = "--main-color: " + color;
			store.set("color", color);
			log.info("Color set to " + color);
		}

		const pickr = Pickr.create({
			el: '.clr-pickr',
			default: 'fff',
			position: 'middle',
			defaultRepresentation: 'HEX',
			components: {
				preview: true,
				opacity: false,
				hue: true,
				interaction: {
					input: true,
					save: true
				}
			},
			strings: {
				save: 'Set color'
			}
		});

		pickr.on("init", function () {
			pickr.setColor(store.get("color", "#ff9900"));
		});

		pickr.on("save", function (hsva) {
			changeColor(hsva.toHEX().toString());
		});

		$scope.openURL = function (url) {
			require("electron").shell.openExternal(url);
		};

		$scope.setRegion = function () {
			store.set("region", $scope.region);
			log.info("Setting default region to: " + $scope.region);
		};

		$scope.setLayout = function () {
			store.set("layout", $scope.layout);
			log.info("Setting default layout to: " + $scope.layout);
		};

		$scope.restart = function () {
			log.info("Restarting Poddr.");
			app.relaunch();
			app.exit(0);
		};

		$scope.openDevTools = function () {
			log.info("Opening DevTools.");
			var mainWindow = require('electron').remote.BrowserWindow.getAllWindows()[0];
			mainWindow.openDevTools();
		};
	});
