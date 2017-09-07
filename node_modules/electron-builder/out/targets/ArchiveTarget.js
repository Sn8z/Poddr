"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.ArchiveTarget = undefined;

var _bluebirdLst;

function _load_bluebirdLst() {
    return _bluebirdLst = require("bluebird-lst");
}

var _builderUtil;

function _load_builderUtil() {
    return _builderUtil = require("builder-util");
}

var _path = _interopRequireWildcard(require("path"));

var _core;

function _load_core() {
    return _core = require("../core");
}

var _archive;

function _load_archive() {
    return _archive = require("./archive");
}

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

class ArchiveTarget extends (_core || _load_core()).Target {
    constructor(name, outDir, packager) {
        super(name);
        this.outDir = outDir;
        this.packager = packager;
        this.options = this.packager.config[this.name];
    }
    build(appOutDir, arch) {
        var _this = this;

        return (0, (_bluebirdLst || _load_bluebirdLst()).coroutine)(function* () {
            const packager = _this.packager;
            const isMac = packager.platform === (_core || _load_core()).Platform.MAC;
            const format = _this.name;
            (0, (_builderUtil || _load_builderUtil()).log)(`Building ${isMac ? "macOS " : ""}${format}`);
            // do not specify arch if x64
            // tslint:disable:no-invalid-template-strings
            const outFile = _path.join(_this.outDir, packager.expandArtifactNamePattern(_this.options, format, arch, packager.platform === (_core || _load_core()).Platform.LINUX ? "${name}-${version}-${arch}.${ext}" : "${productName}-${version}-${arch}-${os}.${ext}"));
            if (format.startsWith("tar.")) {
                yield (0, (_archive || _load_archive()).tar)(packager.config.compression, format, outFile, appOutDir, isMac);
            } else {
                yield (0, (_archive || _load_archive()).archive)(packager.config.compression, format, outFile, appOutDir, { withoutDir: !isMac });
            }
            packager.dispatchArtifactCreated(outFile, _this, arch, isMac ? packager.generateName2(format, "mac", true) : packager.generateName(format, arch, true, packager.platform === (_core || _load_core()).Platform.WINDOWS ? "win" : null));
        })();
    }
}
exports.ArchiveTarget = ArchiveTarget; //# sourceMappingURL=ArchiveTarget.js.map