const { nativeImage, app, ipcMain } = require('electron');
const log = require("electron-log");
const path = require('path');

module.exports = (mainWindow) => {

	const icons = {
		play: nativeImage.createFromPath(path.join(__dirname, './images/play.png')),
		pause: nativeImage.createFromPath(path.join(__dirname, './images/pause.png')),
		next: nativeImage.createFromPath(path.join(__dirname, './images/next.png')),
		prev: nativeImage.createFromPath(path.join(__dirname, './images/prev.png'))
	};

	const tButtons = {
		play: {
			tooltip: 'Play',
			icon: icons.play,
			click: () => {
				mainWindow.webContents.send("player:toggle-play");
			}
		},
		pause: {
			tooltip: 'Pause',
			icon: icons.pause,
			click: () => {
				mainWindow.webContents.send("player:toggle-play");
			}
		},
		next: {
			tooltip: 'Next',
			icon: icons.next,
			click: () => {
				log.info("Next");
			}
		},
		prev: {
			tooltip: 'Previous',
			icon: icons.prev,
			click: () => {
				log.info("Prev");
			}
		}
	};

	app.once("browser-window-focus", () => {
		mainWindow.setThumbarButtons([
			tButtons.prev,
			tButtons.play,
			tButtons.next
		]);
	});

	ipcMain.on("media-play", function () {
		mainWindow.setThumbarButtons([
			tButtons.prev,
			tButtons.pause,
			tButtons.next
		]);
	});

	ipcMain.on("media-pause", function () {
		mainWindow.setThumbarButtons([
			tButtons.prev,
			tButtons.play,
			tButtons.next
		]);
	});
};