const electron = require("electron");
const app = electron.app;
const ipcMain = electron.ipcMain;
const BrowserWindow = electron.BrowserWindow;
const globalShortcut = electron.globalShortcut;
const windowStateKeeper = require("electron-window-state");
var log = require('electron-log');

//Global reference to window object;
var mainWindow = null;

//Quit when all windows are closed
app.on("window-all-closed", function () {
  log.info('Exiting Poddr.');
  app.quit();
});

ipcMain.on('quit-app', function () {
  app.quit();
});

ipcMain.on('raise-app', function () {
  mainWindow.show();
  mainWindow.focus();
});

//When app is rdy, create window
app.once("ready", function () {
  if (process.platform == 'linux') {
    var DBus = require('dbus');
    var session = DBus.getBus('session');

    function registerBindings(desktopEnv, session) {
      session.getInterface(`org.${desktopEnv}.SettingsDaemon`,
        `/org/${desktopEnv}/SettingsDaemon/MediaKeys`,
        `org.${desktopEnv}.SettingsDaemon.MediaKeys`, function (error, iface) {
          if (error) {
            log.info(desktopEnv);
            log.info(error);
          } else {
            iface.on('MediaPlayerKeyPressed', (n, keyName) => {
              switch (keyName) {
                case 'Next': log.info('next'); return;
                case 'Previous': log.info('prev'); return;
                case 'Play': mainWindow.webContents.send("toggle-play", "playpause"); return;
                case 'Stop': log.info('stop'); return;
                default: return;
              }
            });
            iface.GrabMediaPlayerKeys(0, `org.${desktopEnv}.SettingsDaemon.MediaKeys`);
          }
        });
    }

    try {
      registerBindings('gnome', session);
      registerBindings('mate', session);
    } catch (e) {
      log.error(e);
    }

  } else {
    //Global shortcut for Play/Pause toggle, player.js listens for the toggle-play event
    globalShortcut.register("MediaPlayPause", function () {
      mainWindow.webContents.send("toggle-play", "playpause");
    });
  }

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

  mainWindowState.manage(mainWindow);

  mainWindow.on("ready-to-show", function () {
    mainWindow.show();
    mainWindow.focus();
  });

  mainWindow.loadURL("file://" + __dirname + "/app/index.html");

  //Devtools
  //mainWindow.webContents.openDevTools({ mode: 'detach' });

  mainWindow.on("closed", function () {
    mainWindow = null;
  });
});
