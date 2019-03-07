const log = require("electron-log");

(function () {
    async function registerDbus(desktop, bus) {
        var object = await bus.getProxyObject("org." + desktop + ".SettingsDaemon", "/org/" + desktop + "/SettingsDaemon/MediaKeys");
        var mediaKeys = object.getInterface("org." + desktop + ".SettingsDaemon.MediaKeys");
        mediaKeys.on("MediaPlayerKeyPressed", function (iface, changed, invalidated) {
            for (let prop of Object.keys(changed)) {
                log.info(`property changed: ${prop}`);
            }
        });
        mediaKeys.GrabMediaPlayerKeys("org." + desktop + ".SettingsDaemon.MediaKeys", 0);
    }

    try {
        log.info("Registering mediakey bindings.");
        var dbus = require("dbus-next");
        var bus = dbus.sessionBus();
        registerDbus("gnome", bus);
        registerDbus("mate", bus);
    } catch (e) {
        log.error(e);
    }
}());