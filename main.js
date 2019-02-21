const electron = require("electron");
const app = electron.app;
const Menu = electron.Menu;
const ipcMain = electron.ipcMain;
const BrowserWindow = electron.BrowserWindow;
const globalShortcut = electron.globalShortcut;
const nativeImage = electron.nativeImage;
const windowStateKeeper = require("electron-window-state");
const path = require("path");
var log = require("electron-log");

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
app.setPath('userData', app.getPath('userData').replace("Poddr", "poddr"));

//Quit when all windows are closed
app.on("window-all-closed", function () {
  log.info("Exiting Poddr.");
  app.quit();
});

ipcMain.on("quit-app", function () {
  app.quit();
});

ipcMain.on("raise-app", function () {
  mainWindow.show();
  mainWindow.focus();
});

//When app is rdy, create window
app.once("ready", function () {
  if (process.platform == "linux") {
    function registerBindings(desktopEnv, session) {
      session.getInterface(
        `org.${desktopEnv}.SettingsDaemon`,
        `/org/${desktopEnv}/SettingsDaemon/MediaKeys`,
        `org.${desktopEnv}.SettingsDaemon.MediaKeys`,
        function (error, iface) {
          if (error) {
            log.info(desktopEnv);
            log.info(error);
          } else {
            iface.on("MediaPlayerKeyPressed", (n, keyName) => {
              switch (keyName) {
                case "Next":
                  log.info("next");
                  return;
                case "Previous":
                  log.info("prev");
                  return;
                case "Play":
                  mainWindow.webContents.send("toggle-play", "playpause");
                  return;
                case "Stop":
                  log.info("stop");
                  return;
                default:
                  return;
              }
            });
            iface.GrabMediaPlayerKeys(
              0,
              `org.${desktopEnv}.SettingsDaemon.MediaKeys`
            );
          }
        }
      );
    }

    try {
      var DBus = require("dbus");
      var session = DBus.getBus("session");
      registerBindings("gnome", session);
      registerBindings("mate", session);
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


  let icon = path.join(__dirname, "/app/images/icon.png");

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
    backgroundColor: "#0f0f0f",
    icon: nativeImage.createFromPath(icon)
  });

  mainWindowState.manage(mainWindow);

  mainWindow.on("ready-to-show", function () {
    mainWindow.show();
    mainWindow.focus();
  });

  mainWindow.loadURL("file://" + __dirname + "/app/index.html");

  //Devtools
  if (options.debug) {
    log.info("Enabling DevTools.");
    mainWindow.webContents.openDevTools({ mode: "detach" });
  }

  mainWindow.on("closed", function () {
    mainWindow = null;
  });

  //Context & application menus
  if (process.platform == "darwin") {
    var menuTemplate = [
      {
        label: "Poddr",
        submenu: [
          {
            label: "Quit",
            accelerator: "Command+Q",
            click: function () {
              app.quit();
            }
          }
        ]
      },
      {
        label: "Edit",
        submenu: [
          { label: "Cut", accelerator: "CmdOrCtrl+X", selector: "cut:" },
          { label: "Copy", accelerator: "CmdOrCtrl+C", selector: "copy:" },
          { label: "Paste", accelerator: "CmdOrCtrl+V", selector: "paste:" },
          {
            label: "Select All",
            accelerator: "CmdOrCtrl+A",
            selector: "selectAll:"
          }
        ]
      }
    ];
    Menu.setApplicationMenu(Menu.buildFromTemplate(menuTemplate));
  }
  contextMenuTemplate = [
    { label: "Cut", accelerator: "CmdOrCtrl+X", role: "cut" },
    { label: "Copy", accelerator: "CmdOrCtrl+C", role: "copy" },
    { label: "Paste", accelerator: "CmdOrCtrl+V", role: "paste" },
    { label: "Select all", accelerator: "CmdOrCtrl+A", role: "selectall" }
  ];

  mainWindow.webContents.on("context-menu", function (e, params) {
    Menu.buildFromTemplate(contextMenuTemplate).popup(
      mainWindow,
      params.x,
      params.y
    );
  });
});
