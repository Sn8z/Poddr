const electron = require("electron");
const app = electron.app;
const BrowserWindow = electron.BrowserWindow;
const globalShortcut = electron.globalShortcut;
const windowStateKeeper = require("electron-window-state");

//Global reference to window object;
var mainWindow = null;

//Quit when all windows are closed
app.on("window-all-closed", function() {
  app.quit();
});

//When app is rdy, create window
app.on("ready", function() {
  //Global shortcut for Play/Pause toggle, player.js listens for the toggle-play event
  globalShortcut.register("MediaPlayPause", () => {
    console.log("global shortcut pushed");
    mainWindow.webContents.send("toggle-play", "playpause");
  });

  //default window size
  let mainWindowState = windowStateKeeper({
    defaultWidth: 1200,
    defaultHeight: 900
  });

  mainWindow = new BrowserWindow({
    name: "Poddr",
    minWidth: 700,
    minHeight: 600,
    width: mainWindowState.width,
    height: mainWindowState.height,
    x: mainWindowState.x,
    y: mainWindowState.y,
    frame: false,
    show: false,
    backgroundColor: "#0f0f0f",
    icon: __dirname + "/app/images/icon.png"
  });

  //add listeners to the window
  mainWindowState.manage(mainWindow);

  //when main window is ready
  mainWindow.on("ready-to-show", function() {
    mainWindow.show();
    mainWindow.focus();
  });

  //Point to html file to be opened
  mainWindow.loadURL("file://" + __dirname + "/app/index.html");

  //Devtools
  //mainWindow.webContents.openDevTools({ detach: true });

  //Cleanup on window close
  mainWindow.on("closed", function() {
    mainWindow = null;
  });
});
