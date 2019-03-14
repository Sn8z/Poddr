const electron = require("electron");
const app = electron.app;
const BrowserWindow = electron.BrowserWindow;
const ipc = electron.ipcMain;
const mpris = require("mpris-service");
const log = require("electron-log");

(function () {
    log.info("Loading MPRIS module.");
    //get the first spawned window
    var mainWindow = BrowserWindow.getAllWindows()[0];

    mprisPlayer = mpris({
        name: "poddr",
        identity: "Poddr",
        canRaise: true,
        supportedInterfaces: ["player"]
    });

    mprisPlayer.rate = 1 + 1e-15;
    mprisPlayer.minimumRate = 1 + 1e-15;
    mprisPlayer.maximumRate = 1 + 1e-15;
    mprisPlayer.canPlay = true;
    mprisPlayer.canPause = true;
    mprisPlayer.canSeek = false;
    mprisPlayer.canControl = false;
    mprisPlayer.canGoNext = false;
    mprisPlayer.canGoPrevious = false;
    mprisPlayer.canEditTracks = false;
    mprisPlayer.playbackStatus = "Stopped";

    mprisPlayer.on("playpause", function () {
        mainWindow.webContents.send('toggle-play');
    });

    mprisPlayer.on("play", function () {
        if (player.paused) mainWindow.webContents.send('toggle-play');
    });

    mprisPlayer.on("pause", function () {
        if (!player.paused) mainWindow.webContents.send('toggle-play');
    });

    mprisPlayer.on("quit", function () {
        app.quit();
    });

    mprisPlayer.on("raise", function () {
        mainWindow.show();
        mainWindow.focus();
    });

    ipc.on("media-update", function (event, mediaObject) {
        mprisPlayer.metadata = {
            "mpris:artUrl": mediaObject.image,
            "xesam:title": mediaObject.title,
            "xesam:album": "Podcast",
            "xesam:artist": mediaObject.artist
        };
    });

    ipc.on("media-play", function () {
        mprisPlayer.playbackStatus = "Playing";
    });

    ipc.on("media-pause", function () {
        mprisPlayer.playbackStatus = "Stopped";
    });
}());