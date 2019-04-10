const electron = require("electron");
const app = electron.app;
const BrowserWindow = electron.BrowserWindow;
const nativeImage = electron.nativeImage;
const ipc = electron.ipcMain;
const windowStateKeeper = require("electron-window-state");
const path = require("path");
const log = require("electron-log");

//Global reference to window object;
var mainWindow = null;

//Launch options
const options = {
  debug: false
};

const argv = process.argv.slice(1);
log.info("Flags:");
log.info(argv);
for (const arg of argv) {
  if (arg === ".") {
    continue;
  } else if (arg === "--debug" || arg === "-d") {
    log.info("Setting debug to true.");
    options.debug = true;
  } else {
    log.info(arg + " is not a valid flag.");
  }
}

//Fix for correctly naming the app...
app.setPath("userData", app.getPath("userData").replace("Poddr", "poddr"));

//Allow actions before user have interacted with the document
app.commandLine.appendSwitch("--autoplay-policy", "no-user-gesture-required");

//Quit when all windows are closed
app.on("window-all-closed", function() {
  log.info("Exiting Poddr.");
  app.quit();
});

//When app is rdy, create window
app.once("ready", function() {
  //default window size
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
    webPreferences: {
      nodeIntegration: true
    },
    backgroundColor: "#111",
    icon: nativeImage.createFromPath(icon)
  });

  mainWindowState.manage(mainWindow);

  mainWindow.on("ready-to-show", function() {
    //Show and focus window
    mainWindow.show();
    mainWindow.focus();
  });

  mainWindow.loadURL("file://" + __dirname + "/app/poddr/index.html");

  mainWindow.on("closed", function() {
    mainWindow = null;
  });

  //Devtools
  if (options.debug) {
    log.info("Enabling DevTools.");
    mainWindow.webContents.openDevTools({ mode: "detach" });
  }

  require("./utils/contextMenu")();

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
