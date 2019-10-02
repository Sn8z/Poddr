const log = require("electron-log");

module.exports = (mainWindow) => {
  async function registerDbus(desktop, bus) {
    var object = await bus.getProxyObject(
      "org." + desktop + ".SettingsDaemon",
      "/org/" + desktop + "/SettingsDaemon/MediaKeys"
    );
    var mediaKeys = object.getInterface(
      "org." + desktop + ".SettingsDaemon.MediaKeys"
    );
    mediaKeys.on("MediaPlayerKeyPressed", function (interface, key, error) {
      if (error) log.error("Main Process :: " + error);
      switch (key) {
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

    //Grab mediakeys
    mediaKeys.GrabMediaPlayerKeys(
      "org." + desktop + ".SettingsDaemon.MediaKeys",
      0
    );
  }

  try {
    log.info("Main Process :: Registering mediakey bindings using DBUS.");
    var dbus = require("dbus-next");
    var bus = dbus.sessionBus();
    registerDbus("gnome", bus);
    registerDbus("mate", bus);
  } catch (e) {
    log.error("Main Process :: Error binding Dbus interface.");
  }
};
