const app = require("electron").app;
const dbus = require("dbus-next");
const log = require("electron-log");

module.exports = (mainWindow) => {
	const registerDbus = (desktop, bus) => {
		log.info("Main Process :: Trying to register Dbus bindings for " + desktop);
		bus.getProxyObject("org." + desktop + ".SettingsDaemon.MediaKeys", "/org/" + desktop + "/SettingsDaemon/MediaKeys").then((object) => {
			log.info("Main Process :: Got ProxyObject for " + desktop + "!");
			let mediaKeys = object.getInterface("org." + desktop + ".SettingsDaemon.MediaKeys");
			mediaKeys.on("MediaPlayerKeyPressed", (n, keyName) => {
				switch (keyName) {
					case "Next":
						mainWindow.webContents.send("player:next");
						log.info("Main Process :: DBUS => NEXT");
						return;
					case "Previous":
						mainWindow.webContents.send("player:previous");
						log.info("Main Process :: DBUS => PREVIOUS");
						return;
					case "Play":
						mainWindow.webContents.send("player:toggle-play");
						log.info("Main Process :: DBUS => PLAY");
						return;
					case "Stop":
						mainWindow.webContents.send("player:stop");
						log.info("Main Process :: DBUS => STOP");
						return;
					default:
						return;
				}
			});
			app.on("browser-window-focus", () => {
				log.info("Main Process :: Grabbing Mediakeys.");
				mediaKeys.GrabMediaPlayerKeys("org." + desktop + ".SettingsDaemon.MediaKeys", 0);
			});
		}).catch((error) => {
			log.error("ERROR " + error);
		});
	};

	try {
		log.info("Main Process :: Registering mediakey bindings using DBUS.");
		const bus = dbus.sessionBus();
		registerDbus("gnome", bus);
		registerDbus("mate", bus);
	} catch (error) {
		log.error("Main Process :: " + error);
	}
};
