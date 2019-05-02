const globalShortcut = require("electron").globalShortcut;
const log = require("electron-log");

module.exports = (mainWindow) => {
  log.info("Loading globalshortcuts for " + process.platform);

  //Global shortcut for Play/Pause toggle, player.js listens for the toggle-play event
  globalShortcut.register("MediaPlayPause", function () {
    mainWindow.webContents.send("player:toggle-play");
  });
}