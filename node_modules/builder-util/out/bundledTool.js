"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.EXEC_TIMEOUT = undefined;
exports.computeEnv = computeEnv;
exports.computeToolEnv = computeToolEnv;
exports.getLinuxToolsPath = getLinuxToolsPath;

var _binDownload;

function _load_binDownload() {
    return _binDownload = require("./binDownload");
}

// 2 minutes
const EXEC_TIMEOUT = exports.EXEC_TIMEOUT = { timeout: 120 * 1000 };
function computeEnv(oldValue, newValues) {
    const parsedOldValue = oldValue ? oldValue.split(":") : [];
    return newValues.concat(parsedOldValue).filter(it => it.length > 0).join(":");
}
function computeToolEnv(libPath) {
    // noinspection SpellCheckingInspection
    return Object.assign({}, process.env, { DYLD_LIBRARY_PATH: computeEnv(process.env.DYLD_LIBRARY_PATH, libPath) });
}
function getLinuxToolsPath() {
    //noinspection SpellCheckingInspection
    return (0, (_binDownload || _load_binDownload()).getBinFromGithub)("linux-tools", "mac-10.12.2", "i+D1SGCPSKNuR4wZd/lpiW5l1emfX1MgkNwESqOXKgh5SpN3TNV9oi0W6zD9fEDwCBJaMYsZJtSjulh16TzKEA==");
}
//# sourceMappingURL=bundledTool.js.map