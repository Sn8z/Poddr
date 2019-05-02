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
      if (error) log.error(error);
      switch (key) {
        case "Next":
          mainWindow.webContents.send("player:next");
          log.info("DBUS => NEXT");
          return;
        case "Previous":
          mainWindow.webContents.send("player:previous");
          log.info("DBUS => PREVIOUS");
          return;
        case "Play":
          mainWindow.webContents.send("player:toggle-play");
          log.info("DBUS => PLAY");
          return;
        case "Stop":
          mainWindow.webContents.send("player:stop");
          log.info("DBUS => STOP");
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
    log.info("Registering mediakey bindings using DBUS.");
    var dbus = require("dbus-next");
    var bus = dbus.sessionBus();
    registerDbus("gnome", bus);
    registerDbus("mate", bus);
  } catch (e) {
    log.error("Error binding Dbus interface.");
  }
};
