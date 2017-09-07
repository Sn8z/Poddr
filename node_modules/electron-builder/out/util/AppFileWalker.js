"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.AppFileWalker = undefined;

var _bluebirdLst;

function _load_bluebirdLst() {
    return _bluebirdLst = require("bluebird-lst");
}

var _bluebirdLst2;

function _load_bluebirdLst2() {
    return _bluebirdLst2 = _interopRequireDefault(require("bluebird-lst"));
}

var _fs;

function _load_fs() {
    return _fs = require("builder-util/out/fs");
}

var _fsExtraP;

function _load_fsExtraP() {
    return _fsExtraP = require("fs-extra-p");
}

var _path = _interopRequireWildcard(require("path"));

var _packageDependencies;

function _load_packageDependencies() {
    return _packageDependencies = require("./packageDependencies");
}

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

const nodeModulesSystemDependentSuffix = `${_path.sep}node_modules`;
const excludedFiles = new Set([".DS_Store", "node_modules" /* already in the queue */, "CHANGELOG.md", "ChangeLog", "changelog.md", "binding.gyp"]);
/** @internal */
class AppFileWalker {
    constructor(matcher, packager) {
        this.matcher = matcher;
        this.packager = packager;
        this.metadata = new Map();
        if (!matcher.isSpecifiedAsEmptyArray && (matcher.isEmpty() || matcher.containsOnlyIgnore())) {
            matcher.prependPattern("**/*");
        }
        this.filter = matcher.createFilter();
    }
    // noinspection JSUnusedGlobalSymbols
    consume(file, fileStat, parent, siblingNames) {
        if (fileStat.isDirectory()) {
            // https://github.com/electron-userland/electron-builder/issues/1539
            // but do not filter if we inside node_modules dir
            if (file.endsWith(nodeModulesSystemDependentSuffix) && !(parent.indexOf("node_modules") !== -1) && siblingNames.indexOf("package.json") !== -1) {
                return this.handleNodeModulesDir(file, parent);
            }
        } else {
            // save memory - no need to store stat for directory
            this.metadata.set(file, fileStat);
        }
        return this.handleFile(file, fileStat);
    }
    handleNodeModulesDir(nodeModulesDir, parent) {
        const packager = this.packager;
        return (parent === packager.appDir ? packager.productionDeps.value : (0, (_packageDependencies || _load_packageDependencies()).getProductionDependencies)(parent)).then(it => {
            if (packager.debugLogger.enabled) {
                packager.debugLogger.add(`productionDependencies.${parent}`, it.filter(it => it.path.startsWith(nodeModulesDir)).map(it => _path.relative(nodeModulesDir, it.path)));
            }
            return this.copyNodeModules(it, this.filter, (file, fileStat) => {
                this.metadata.set(file, fileStat);
                return this.handleFile(file, fileStat);
            });
        });
    }
    handleFile(file, fileStat) {
        if (!fileStat.isSymbolicLink()) {
            return null;
        }
        return (0, (_fsExtraP || _load_fsExtraP()).readlink)(file).then(linkTarget => {
            // http://unix.stackexchange.com/questions/105637/is-symlinks-target-relative-to-the-destinations-parent-directory-and-if-so-wh
            return this.handleSymlink(fileStat, file, _path.resolve(_path.dirname(file), linkTarget));
        });
    }
    handleSymlink(fileStat, file, linkTarget) {
        const link = _path.relative(this.matcher.from, linkTarget);
        if (link.startsWith("..")) {
            // outside of project, linked module (https://github.com/electron-userland/electron-builder/issues/675)
            return (0, (_fsExtraP || _load_fsExtraP()).stat)(linkTarget).then(targetFileStat => {
                this.metadata.set(file, targetFileStat);
                return targetFileStat;
            });
        } else {
            fileStat.relativeLink = link;
        }
        return null;
    }
    copyNodeModules(list, filter, consumer) {
        var _this = this;

        return (0, (_bluebirdLst || _load_bluebirdLst()).coroutine)(function* () {
            const result = [];
            const queue = [];
            for (const dep of list) {
                queue.length = 1;
                queue[0] = dep.path;
                if (dep.link != null) {
                    _this.metadata.set(dep.path, dep.stat);
                    const r = _this.handleSymlink(dep.stat, dep.path, dep.link);
                    if (r != null) {
                        yield r;
                    }
                }
                while (queue.length > 0) {
                    const dirPath = queue.pop();
                    const childNames = yield (0, (_fsExtraP || _load_fsExtraP()).readdir)(dirPath);
                    childNames.sort();
                    const dirs = [];
                    // our handler is async, but we should add sorted files, so, we add file to result not in the mapper, but after map
                    const sortedFilePaths = yield (_bluebirdLst2 || _load_bluebirdLst2()).default.map(childNames, function (name) {
                        if (excludedFiles.has(name) || name.endsWith(".h") || name.endsWith(".o") || name.endsWith(".obj") || name.endsWith(".cc") || name.endsWith(".pdb") || name.endsWith(".d.ts")) {
                            return null;
                        }
                        if (dirPath.endsWith("build")) {
                            if (name === "gyp-mac-tool" || name === "Makefile" || name.endsWith(".mk") || name.endsWith(".gypi") || name.endsWith(".Makefile")) {
                                return null;
                            }
                        } else if (dirPath.endsWith("Release") && (name === ".deps" || name === "obj.target")) {
                            return null;
                        } else if (name === "src" && (dirPath.endsWith("keytar") || dirPath.endsWith("keytar-prebuild"))) {
                            return null;
                        } else if (dirPath.endsWith("lzma-native") && (name === "build" || name === "deps")) {
                            return null;
                        }
                        const filePath = dirPath + _path.sep + name;
                        return (0, (_fsExtraP || _load_fsExtraP()).lstat)(filePath).then(function (stat) {
                            if (filter != null && !filter(filePath, stat)) {
                                return null;
                            }
                            const consumerResult = consumer(filePath, stat, dirPath, childNames);
                            if (consumerResult == null || !("then" in consumerResult)) {
                                if (stat.isDirectory()) {
                                    dirs.push(name);
                                    return null;
                                } else {
                                    return filePath;
                                }
                            } else {
                                return consumerResult.then(function (it) {
                                    // asarUtil can return modified stat (symlink handling)
                                    if ((it != null && "isDirectory" in it ? it : stat).isDirectory()) {
                                        dirs.push(name);
                                        return null;
                                    } else {
                                        return filePath;
                                    }
                                });
                            }
                        });
                    }, (_fs || _load_fs()).CONCURRENCY);
                    for (const child of sortedFilePaths) {
                        if (child != null) {
                            result.push(child);
                        }
                    }
                    dirs.sort();
                    for (const child of dirs) {
                        queue.push(dirPath + _path.sep + child);
                    }
                }
            }
            return result;
        })();
    }
}
exports.AppFileWalker = AppFileWalker; //# sourceMappingURL=AppFileWalker.js.map