const globalShortcut = require('electron').globalShortcut;
const log = require('electron-log');

module.exports = (mainWindow) => {
	log.info('Loading globalshortcuts for ' + process.platform);
	globalShortcut.register('MediaPlayPause', function () {
		mainWindow.webContents.send('player:toggle-play');
	});
};