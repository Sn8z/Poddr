const electron = require("electron");
const globalShortcut = electron.globalShortcut;
const BrowserWindow = electron.BrowserWindow;
const log = require("electron-log");

(function () {
    log.info("Loading globalshortcuts for " + process.platform);
    mainWindow = BrowserWindow.getAllWindows()[0];

    //Global shortcut for Play/Pause toggle, player.js listens for the toggle-play event
    globalShortcut.register('MediaPlayPause', function () {
        mainWindow.webContents.send('toggle-play');
    });
}());