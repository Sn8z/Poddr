const { app, Menu, Tray, nativeImage } = require('electron');
const path = require("path");
const log = require("electron-log");

let tray = null;
module.exports = (mainWindow) => {
	log.info("Main Process :: Loading Tray module.");
	try {
		const iconPath = path.join(__dirname, './images/logo.png');
		tray = new Tray(nativeImage.createFromPath(iconPath));
		const ctxMenu = Menu.buildFromTemplate([{
			label: 'Poddr', click: () => {
				log.info("Main Process :: Tray => Showing Poddr");
				mainWindow.show();
				mainWindow.focus();
			}
		},
		{
			type: 'separator'
		}, {
			label: 'Play / Pause', click: () => {
				log.info("Main Process :: Tray => Toggle Play / Pause");
				mainWindow.webContents.send('player:toggle-play');
			}
		}, {
			type: 'separator'
		}, {
			label: 'Quit Poddr', click: () => {
				log.info("Main Process :: Tray => Exiting app");
				app.quit();
			}
		}]);
		tray.setToolTip('Poddr');
		tray.on('click', () => {
			log.info("Main Process :: Tray => Showing Poddr");
			mainWindow.show();
			mainWindow.focus();
		});
		tray.setContextMenu(ctxMenu);
	} catch (error) {
		log.error("Main Process :: Tray => " + error);
	}
};