#! /usr/bin/env node

"use strict";

var _bluebirdLst;

function _load_bluebirdLst() {
    return _bluebirdLst = require("bluebird-lst");
}

let rebuildAppNativeCode = (() => {
    var _ref = (0, (_bluebirdLst || _load_bluebirdLst()).coroutine)(function* (args) {
        const projectDir = process.cwd();
        (0, (_builderUtil || _load_builderUtil()).log)(`Execute node-gyp rebuild for ${args.platform}:${args.arch}`);
        // this script must be used only for electron
        yield (0, (_builderUtil || _load_builderUtil()).exec)(process.platform === "win32" ? "node-gyp.cmd" : "node-gyp", ["rebuild"], {
            env: (0, (_yarn || _load_yarn()).getGypEnv)({ version: yield (0, (_electronVersion || _load_electronVersion()).getElectronVersion)(projectDir), useCustomDist: true }, args.platform, args.arch, true)
        });
    });

    return function rebuildAppNativeCode(_x) {
        return _ref.apply(this, arguments);
    };
})();

let loadEnv = (() => {
    var _ref2 = (0, (_bluebirdLst || _load_bluebirdLst()).coroutine)(function* (envFile) {
        const data = yield (0, (_readConfigFile || _load_readConfigFile()).orNullIfFileNotExist)((0, (_fsExtraP || _load_fsExtraP()).readFile)(envFile, "utf8"));
        if (data == null) {
            return null;
        }
        const parsed = (0, (_dotenv || _load_dotenv()).parse)(data);
        for (const key of Object.keys(parsed)) {
            if (!process.env.hasOwnProperty(key)) {
                process.env[key] = parsed[key];
            }
        }
        require("dotenv-expand")(parsed);
        return parsed;
    });

    return function loadEnv(_x2) {
        return _ref2.apply(this, arguments);
    };
})();
//# sourceMappingURL=cli.js.map


var _builderUtil;

function _load_builderUtil() {
    return _builderUtil = require("builder-util");
}

var _promise;

function _load_promise() {
    return _promise = require("builder-util/out/promise");
}

var _chalk;

function _load_chalk() {
    return _chalk = require("chalk");
}

var _dotenv;

function _load_dotenv() {
    return _dotenv = require("dotenv");
}

var _fsExtraP;

function _load_fsExtraP() {
    return _fsExtraP = require("fs-extra-p");
}

var _isCi;

function _load_isCi() {
    return _isCi = _interopRequireDefault(require("is-ci"));
}

var _path = _interopRequireWildcard(require("path"));

var _readConfigFile;

function _load_readConfigFile() {
    return _readConfigFile = require("read-config-file");
}

var _updateNotifier;

function _load_updateNotifier() {
    return _updateNotifier = _interopRequireDefault(require("update-notifier"));
}

var _yargs;

function _load_yargs() {
    return _yargs = _interopRequireDefault(require("yargs"));
}

var _builder;

function _load_builder() {
    return _builder = require("../builder");
}

var _electronVersion;

function _load_electronVersion() {
    return _electronVersion = require("../util/electronVersion");
}

var _yarn;

function _load_yarn() {
    return _yarn = require("../util/yarn");
}

var _createSelfSignedCert;

function _load_createSelfSignedCert() {
    return _createSelfSignedCert = require("./create-self-signed-cert");
}

var _installAppDeps;

function _load_installAppDeps() {
    return _installAppDeps = require("./install-app-deps");
}

var _start;

function _load_start() {
    return _start = require("./start");
}

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// tslint:disable:no-unused-expression
(_yargs || _load_yargs()).default.command(["build", "*"], "Build", (_builder || _load_builder()).configureBuildCommand, wrap((_builder || _load_builder()).build)).command("install-app-deps", "Install app deps", (_installAppDeps || _load_installAppDeps()).configureInstallAppDepsCommand /* yes, args the same as for install app deps */, wrap((_installAppDeps || _load_installAppDeps()).installAppDeps)).command("node-gyp-rebuild", "Rebuild own native code", (_installAppDeps || _load_installAppDeps()).configureInstallAppDepsCommand, wrap(rebuildAppNativeCode)).command("create-self-signed-cert", "Create self-signed code signing cert for Windows apps", yargs => yargs.option("publisher", {
    alias: ["p"],
    type: "string",
    requiresArg: true,
    description: "The publisher name"
}).demandOption("publisher"), wrap(argv => (0, (_createSelfSignedCert || _load_createSelfSignedCert()).createSelfSignedCert)(argv.publisher))).command("start", "Run application in a development mode using electron-webpack", yargs => yargs, wrap(argv => (0, (_start || _load_start()).start)())).help().epilog(`See ${(0, (_chalk || _load_chalk()).underline)("https://electron.build")} for more documentation.`).strict().argv;
function wrap(task) {
    return args => {
        checkIsOutdated();
        loadEnv(_path.join(process.cwd(), "electron-builder.env")).then(() => task(args)).catch((_promise || _load_promise()).printErrorAndExit);
    };
}
function checkIsOutdated() {
    if ((_isCi || _load_isCi()).default || process.env.NO_UPDATE_NOTIFIER != null) {
        return;
    }
    (0, (_fsExtraP || _load_fsExtraP()).readJson)(_path.join(__dirname, "..", "..", "package.json")).then(it => {
        if (it.version === "0.0.0-semantic-release") {
            return;
        }
        const notifier = (0, (_updateNotifier || _load_updateNotifier()).default)({ pkg: it });
        if (notifier.update != null) {
            notifier.notify({
                message: `Update available ${(0, (_chalk || _load_chalk()).dim)(notifier.update.current)}${(0, (_chalk || _load_chalk()).reset)(" → ")}${(0, (_chalk || _load_chalk()).green)(notifier.update.latest)} \nRun ${(0, (_chalk || _load_chalk()).cyan)("yarn upgrade electron-builder")} to update`
            });
        }
    }).catch(e => (0, (_builderUtil || _load_builderUtil()).warn)(`Cannot check updates: ${e}`));
}