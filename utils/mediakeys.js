const { globalShortcut, app } = require('electron');
const log = require('electron-log');

module.exports = (mainWindow) => {
	log.info('Main Process :: Loading globalshortcuts for ' + process.platform);
	app.on('browser-window-focus', () => {
		log.info('Main Process :: Grabbing Mediakeys.');
		globalShortcut.register('MediaPlayPause', function () {
			mainWindow.webContents.send('player:toggle-play');
		});
	});
};