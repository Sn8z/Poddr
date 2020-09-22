const electron = require("electron");
const app = electron.app;
const BrowserWindow = electron.BrowserWindow;
const nativeImage = electron.nativeImage;
const ipc = electron.ipcMain;
const windowStateKeeper = require("electron-window-state");
const path = require("path");

//Global reference to window object;
var mainWindow = null;

//Fix for correctly naming the app...
app.setPath("userData", app.getPath("userData").replace("Poddr", "poddr"));

//Set up logging
const log = require("electron-log");
log.transports.file.init();
log.info("Main Process :: Storing logs at: " + log.transports.file.file);

//Allow actions before user have interacted with the document
app.commandLine.appendSwitch("--autoplay-policy", "no-user-gesture-required");

//Launch options
const options = {
	debug: false
};

const argv = process.argv.slice(1);
log.info("Main Process :: Flags: " + argv);
for (const arg of argv) {
	if (arg === ".") {
		continue;
	} else if (arg === "--debug" || arg === "-d") {
		log.info("Main Process :: Setting debug to true.");
		options.debug = true;
	} else {
		log.info("Main Process :: " + arg + " is not a valid flag.");
	}
}

//Quit when all windows are closed
app.on("window-all-closed", function () {
	log.info("Main Process :: Exiting Poddr.");
	app.quit();
});

//When app is ready, create window
app.once("ready", function () {

	let mainWindowState = windowStateKeeper({
		defaultWidth: 1200,
		defaultHeight: 900
	});

	let icon = path.join(__dirname, "/app/poddr/assets/images/logo.png");

	mainWindow = new BrowserWindow({
		name: "Poddr",
		minWidth: 640,
		minHeight: 600,
		width: mainWindowState.width,
		height: mainWindowState.height,
		x: mainWindowState.x,
		y: mainWindowState.y,
		frame: false,
		show: false,
		simpleFullscreen: true,
		webPreferences: {
			nodeIntegration: true
		},
		backgroundColor: "#111",
		icon: nativeImage.createFromPath(icon)
	});

	mainWindowState.manage(mainWindow);

	mainWindow.on("ready-to-show", function () {
		mainWindow.show();
		mainWindow.focus();
	});

	mainWindow.loadURL("file://" + __dirname + "/app/poddr/index.html");

	mainWindow.once("close", function (event) {
		event.preventDefault();
		log.info("Main Process :: Closing app.");
		mainWindow.webContents.send("app:close");
	});

	ipc.once("app:closed", function () {
		app.quit();
	});

	mainWindow.on("closed", function () {
		mainWindow = null;
	});

	//Devtools
	if (options.debug) {
		log.info("Main Process :: Enabling DevTools.");
		mainWindow.webContents.openDevTools({ mode: "detach" });
	}

	require("./utils/contextMenu")(mainWindow);

	if (process.platform == "linux") {
		require("./utils/mpris")(mainWindow);
		require("./utils/dbus")(mainWindow);
	} else {
		require("./utils/mediakeys")(mainWindow);
	}

	//Listen for window changes
	ipc.on("window-update", (event, arg) => {
		switch (arg) {
			case "minimize":
				mainWindow.minimize();
				break;
			case "maximize":
				if (mainWindow.isMaximized()) {
					mainWindow.unmaximize();
				} else {
					mainWindow.maximize();
				}
				break;
			case "close":
				app.quit();
				break;
			default:
				break;
		}
	});
});
