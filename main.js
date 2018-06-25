const electron = require("electron");
const app = electron.app;
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

//When app is rdy, create window
app.once("ready", function () {
  log.info(process.platform);
  if (process.platform == 'linux') {
    function registerBindings(desktopEnv, session) {
      session.getInterface(`org.${desktopEnv}.SettingsDaemon`,
        `/org/${desktopEnv}/SettingsDaemon/MediaKeys`,
        `org.${desktopEnv}.SettingsDaemon.MediaKeys`, (err, iface) => {
          if (err) {
            log.info(desktopEnv);
            log.info(err);
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
      var DBus = require('dbus');
      var session = DBus.getBus('session');

      registerBindings('gnome', session);
      registerBindings('mate', session);
    } catch (e) {
      log.error(e);
    }

  } else {
    //Global shortcut for Play/Pause toggle, player.js listens for the toggle-play event
    globalShortcut.register("MediaPlayPause", () => {
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

  //add listeners to the window
  mainWindowState.manage(mainWindow);

  //when main window is ready
  mainWindow.on("ready-to-show", function () {
    mainWindow.show();
    mainWindow.focus();
  });

  //Point to html file to be opened
  mainWindow.loadURL("file://" + __dirname + "/app/index.html");

  //Devtools
  //mainWindow.webContents.openDevTools({ mode: 'detach' });

  //Cleanup on window close
  mainWindow.on("closed", function () {
    mainWindow = null;
  });
});
