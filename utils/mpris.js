const electron = require("electron");
const app = electron.app;
const ipc = electron.ipcMain;
const Mpris = require("mpris-service");
const log = require("electron-log");

module.exports = (mainWindow) => {
  log.info("Main Process :: Loading MPRIS module.");

  let mprisPlayer = Mpris({
    name: "poddr",
    identity: "Poddr",
    canRaise: true,
    supportedInterfaces: ["player"],
    supportedUriSchemes: ["file", "http", "https"],
    SupportedMimeTypes: [
      "audio/mpeg",
      "audio/ogg",
      "audio/x-m4a",
      "audio/wav",
      "audio/webm",
      "audio/flac",
    ],
    HasTrackList: false,
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
    mainWindow.webContents.send("player:toggle-play");
    log.info("Main Process :: MPRIS => Play / Pause");
  });

  mprisPlayer.on("play", function () {
    mainWindow.webContents.send("player:toggle-play");
    log.info("Main Process :: MPRIS => Play");
  });

  mprisPlayer.on("pause", function () {
    mainWindow.webContents.send("player:toggle-play");
    log.info("Main Process :: MPRIS => Pause");
  });

  mprisPlayer.on("quit", function () {
    app.quit();
  });

  mprisPlayer.on("raise", function () {
    mainWindow.show();
    mainWindow.focus();
  });

  ipc.on("media-update", function (event, mediaObject) {
    log.info("Main Process :: MPRIS => Media update.");
    mprisPlayer.metadata = {
      "mpris:artUrl": mediaObject.image || "",
      "xesam:title": mediaObject.title || "No title",
      "xesam:album": "Podcast",
      "xesam:artist": [mediaObject.artist || "No artist"],
    };
  });

  ipc.on("media-play", function () {
    mprisPlayer.playbackStatus = "Playing";
  });

  ipc.on("media-pause", function () {
    mprisPlayer.playbackStatus = "Stopped";
  });
};
