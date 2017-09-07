"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.computeLicensePage = undefined;

var _bluebirdLst;

function _load_bluebirdLst() {
    return _bluebirdLst = require("bluebird-lst");
}

let computeLicensePage = exports.computeLicensePage = (() => {
    var _ref = (0, (_bluebirdLst || _load_bluebirdLst()).coroutine)(function* (packager, options, scriptGenerator, languages) {
        const possibleFiles = [];
        for (const name of ["license", "eula"]) {
            for (const ext of ["rtf", "txt", "html"]) {
                possibleFiles.push(`${name}.${ext}`);
                possibleFiles.push(`${name.toUpperCase()}.${ext}`);
                possibleFiles.push(`${name}.${ext.toUpperCase()}`);
                possibleFiles.push(`${name.toUpperCase()}.${ext.toUpperCase()}`);
            }
        }
        const license = yield packager.getResource.apply(packager, [options.license].concat(possibleFiles));
        if (license != null) {
            let licensePage;
            if (license.endsWith(".html")) {
                licensePage = ["!define MUI_PAGE_CUSTOMFUNCTION_SHOW LicenseShow", "Function LicenseShow", "  FindWindow $R0 `#32770` `` $HWNDPARENT", "  GetDlgItem $R0 $R0 1000", "EmbedHTML::Load /replace $R0 file://$PLUGINSDIR\\license.html", "FunctionEnd", `!insertmacro MUI_PAGE_LICENSE "${_path.join((_nsisUtil || _load_nsisUtil()).nsisTemplatesDir, "empty-license.txt")}"`];
            } else {
                licensePage = [`!insertmacro MUI_PAGE_LICENSE "${license}"`];
            }
            scriptGenerator.macro("licensePage", licensePage);
            if (license.endsWith(".html")) {
                scriptGenerator.macro("addLicenseFiles", [`File /oname=$PLUGINSDIR\\license.html "${license}"`]);
            }
            return;
        }
        const licenseFiles = yield (0, (_license || _load_license()).getLicenseFiles)(packager);
        if (licenseFiles.length === 0) {
            return;
        }
        const licensePage = [];
        const unspecifiedLangs = new Set(languages);
        let defaultFile = null;
        for (const item of licenseFiles) {
            unspecifiedLangs.delete(item.langWithRegion);
            if (defaultFile == null) {
                defaultFile = item.file;
            }
            licensePage.push(`LicenseLangString MUILicense ${(_langs || _load_langs()).lcid[item.langWithRegion] || item.lang} "${item.file}"`);
        }
        for (const l of unspecifiedLangs) {
            licensePage.push(`LicenseLangString MUILicense ${(_langs || _load_langs()).lcid[l]} "${defaultFile}"`);
        }
        licensePage.push('!insertmacro MUI_PAGE_LICENSE "$(MUILicense)"');
        scriptGenerator.macro("licensePage", licensePage);
    });

    return function computeLicensePage(_x, _x2, _x3, _x4) {
        return _ref.apply(this, arguments);
    };
})();
//# sourceMappingURL=nsisLicense.js.map


var _langs;

function _load_langs() {
    return _langs = require("builder-util/out/langs");
}

var _license;

function _load_license() {
    return _license = require("builder-util/out/license");
}

var _path = _interopRequireWildcard(require("path"));

var _nsisUtil;

function _load_nsisUtil() {
    return _nsisUtil = require("./nsisUtil");
}

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }