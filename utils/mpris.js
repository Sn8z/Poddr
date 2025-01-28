import { app, ipcMain } from "electron";
import Mpris from "mpris-service";
import log from "electron-log";

class MprisService {
  constructor(mainWindow) {
    this.mainWindow = mainWindow;
    this.mprisPlayer = null;
    this.initialize();
  }

  initialize() {
    try {
      log.info("Main Process :: Loading MPRIS module.");

      this.mprisPlayer = Mpris({
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

      this.setupPlayerDefaults();
      this.setupEventListeners();
      this.setupIpcHandlers();
    } catch (error) {
      log.error("Main Process :: Failed to initialize MPRIS:", error);
      throw new Error("Failed to initialize MPRIS service");
    }
  }

  setupPlayerDefaults() {
    const epsilon = 1e-15;
    const defaultRate = 1 + epsilon;

    try {
      this.mprisPlayer.rate = defaultRate;
      this.mprisPlayer.minimumRate = defaultRate;
      this.mprisPlayer.maximumRate = defaultRate;

      this.mprisPlayer.canPlay = true;
      this.mprisPlayer.canPause = true;
      this.mprisPlayer.canSeek = false;
      this.mprisPlayer.canControl = false;
      this.mprisPlayer.canGoNext = false;
      this.mprisPlayer.canGoPrevious = false;
      this.mprisPlayer.canEditTracks = false;

      this.mprisPlayer.playbackStatus = "Stopped";
    } catch (error) {
      log.error("Main Process :: Failed to setup MPRIS defaults:", error);
      throw new Error("Failed to setup MPRIS player defaults");
    }
  }

  setupEventListeners() {
    try {
      this.mprisPlayer.on("playpause", () => {
        this.mainWindow.webContents.send("player:toggle-play");
        log.info("Main Process :: MPRIS => Play / Pause");
      });

      this.mprisPlayer.on("play", () => {
        this.mainWindow.webContents.send("player:toggle-play");
        log.info("Main Process :: MPRIS => Play");
      });

      this.mprisPlayer.on("pause", () => {
        this.mainWindow.webContents.send("player:toggle-play");
        log.info("Main Process :: MPRIS => Pause");
      });

      this.mprisPlayer.on("quit", () => {
        app.quit();
      });

      this.mprisPlayer.on("raise", () => {
        if (!this.mainWindow.isDestroyed()) {
          this.mainWindow.show();
          this.mainWindow.focus();
        }
      });
    } catch (error) {
      log.error(
        "Main Process :: Failed to setup MPRIS event listeners:",
        error
      );
      throw new Error("Failed to setup MPRIS event listeners");
    }
  }

  setupIpcHandlers() {
    try {
      ipcMain.on("media-update", (_, mediaObject) => {
        log.info("Main Process :: MPRIS => Media update.");

        try {
          this.mprisPlayer.metadata = {
            "mpris:artUrl": mediaObject.image || "",
            "xesam:title": mediaObject.title || "No title",
            "xesam:album": "Podcast",
            "xesam:artist": [mediaObject.artist || "No artist"],
          };
        } catch (error) {
          log.error("Main Process :: Failed to update MPRIS metadata:", error);
        }
      });

      ipcMain.on("media-play", () => {
        try {
          this.mprisPlayer.playbackStatus = "Playing";
        } catch (error) {
          log.error(
            "Main Process :: Failed to update MPRIS play status:",
            error
          );
        }
      });

      ipcMain.on("media-pause", () => {
        try {
          this.mprisPlayer.playbackStatus = "Stopped";
        } catch (error) {
          log.error(
            "Main Process :: Failed to update MPRIS pause status:",
            error
          );
        }
      });
    } catch (error) {
      log.error("Main Process :: Failed to setup MPRIS IPC handlers:", error);
      throw new Error("Failed to setup MPRIS IPC handlers");
    }
  }

  destroy() {
    try {
      if (this.mprisPlayer) {
        ipcMain.removeAllListeners("media-update");
        ipcMain.removeAllListeners("media-play");
        ipcMain.removeAllListeners("media-pause");

        this.mprisPlayer.removeAllListeners();
        this.mprisPlayer = null;
      }
    } catch (error) {
      log.error("Main Process :: Failed to cleanup MPRIS service:", error);
    }
  }
}

export default function createMprisService(mainWindow) {
  if (!mainWindow) {
    throw new Error("MainWindow is required for MPRIS service");
  }
  return new MprisService(mainWindow);
}
