const {
  app,
  BrowserWindow,
  nativeImage,
  ipcMain,
  dialog,
} = require("electron");
const windowStateKeeper = require("electron-window-state");
const path = require("path");
const store = require("electron-store");
const log = require("electron-log");

let mainWindow = null;

const options = {
  debug: process.argv.includes("--debug") || process.argv.includes("-d"),
};

function setupLogging() {
  log.info(
    `Main Process :: Storing logs at: ${log.transports.file.getFile().path}`
  );
  if (options.debug) {
    process.traceDeprecation = true;
    process.traceProcessWarnings = true;
  }
}

function createWindow() {
  const mainWindowState = windowStateKeeper({
    defaultWidth: 1200,
    defaultHeight: 900,
  });

  const icon = path.join(__dirname, "/app/poddr/assets/images/logo.png");

  mainWindow = new BrowserWindow({
    title: "Poddr",
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
      nodeIntegration: true,
      contextIsolation: false,
      sandbox: false,
      devTools: options.debug,
    },
    backgroundColor: "#111",
    icon: nativeImage.createFromPath(icon),
  });

  mainWindowState.manage(mainWindow);

  return mainWindow;
}

function setupWindowEvents(window) {
  window.on("ready-to-show", () => {
    window.show();
    window.focus();
  });

  window.once("close", async (event) => {
    event.preventDefault();
    log.info("Main Process :: Closing app.");
    window.webContents.send("app:close");
  });

  window.on("closed", () => {
    mainWindow = null;
  });

  if (options.debug) {
    log.info("Main Process :: Enabling DevTools.");
    window.webContents.openDevTools({ mode: "detach" });
  }
}

function setupIpcHandlers(window) {
  ipcMain.handle("appVersion", () => app.getVersion());
  ipcMain.handle("appStorage", () => app.getPath("userData"));
  ipcMain.handle("logStorage", () => log.transports.file.getFile().path);
  ipcMain.handle("downloadStorage", () =>
    path.join(app.getPath("downloads"), "Poddr")
  );

  ipcMain.handle("openDialog", () => {
    return dialog.showOpenDialog({
      buttonLabel: "Import OPML file",
      filters: [{ name: "OPML", extensions: ["opml", "xml"] }],
      properties: ["showHiddenFiles", "openFile"],
    });
  });

  ipcMain.handle("saveDialog", () => {
    return dialog.showSaveDialog({
      buttonLabel: "Save OPML file",
      filters: [{ name: "OPML", extensions: ["opml", "xml"] }],
    });
  });

  ipcMain.once("app:closed", () => {
    app.quit();
  });

  ipcMain.on("window-update", (_, action) => {
    switch (action) {
      case "minimize":
        window.minimize();
        break;
      case "maximize":
        window.isMaximized() ? window.unmaximize() : window.maximize();
        break;
      case "close":
        app.quit();
        break;
    }
  });

  ipcMain.on("relaunch", () => {
    app.relaunch();
    app.exit(0);
  });

  ipcMain.on("toggleDevTools", () => {
    window.openDevTools();
  });
}

function setupPlatformSpecific(window) {
  require("./utils/contextMenu")(window);
  require("./utils/tray")(window);

  if (process.platform === "linux") {
    require("./utils/mpris")(window);
    require("./utils/dbus")(window);
  } else {
    require("./utils/mediakeys")(window);
    require("./utils/thumbarButtons")(window);
  }
}

function init() {
  app.setPath("userData", app.getPath("userData").replace("Poddr", "poddr"));

  app.commandLine.appendSwitch("--autoplay-policy", "no-user-gesture-required");

  store.initRenderer();

  setupLogging();

  app.on("window-all-closed", () => {
    log.info("Main Process :: Exiting Poddr.");
    app.quit();
  });

  app.once("ready", () => {
    const window = createWindow();
    setupWindowEvents(window);
    setupIpcHandlers(window);
    setupPlatformSpecific(window);
    window.loadFile(path.join(__dirname, "/app/poddr/index.html"));
  });
}

init();
