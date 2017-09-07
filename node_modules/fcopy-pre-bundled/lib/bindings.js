'use strict';
const fs = require('fs');
const path = require('path');

const URL = 'https://github.com/sciolist/fcopy/releases/download/bin-v{0}/{1}.node';

function fsmkdir(path) {
    return new Promise(function fsmkdir(resolve, reject) {
        fs.mkdir(path, function result(err) {
            if (err) { reject(err); return; }
            resolve();
        });
    });
}

function fsexists(path) {
    return new Promise(function fsexists(resolve, reject) {
        fs.exists(path, function result(exists) { resolve(exists); });
    });
}

const versionInfo = {
    abi: process.versions.modules,
    arch: process.arch,
    binversion: 1,
    platform: process.platform,
};

function buildModuleName(info) {
    return info.binversion + '-' + info.abi + '-' + info.platform + '-' + info.arch;
}
const bindingRoot = path.dirname(__filename) + '/fcopy_binding';
function downloadIfNeeded(versionInfo) {
    const fileName = buildModuleName(versionInfo);
    console.log('downloading', fileName);
    const target = bindingRoot + '/' + fileName + '.node';
    const url = URL.replace('{0}', versionInfo.binversion).replace('{1}', fileName);
    return createBindingDirectory()
        .then(function f1() { return fsexists(target); })
        .then(function f2(found) { return found || httpDownload(url, target); });
}

function createBindingDirectory() {
    return fsexists(bindingRoot).then(function f1(found) {
        if (!found) { return fsmkdir(bindingRoot); }
        return true;
    });
}

function httpDownload(url, target) {
    const https = require('https');
    return new Promise(function startDownload(resolve, reject) {
        https.get(url, processDownload);

        function processDownload(res) {
            if (res.statusCode === 301 || res.statusCode === 302) {
                https.get(res.headers.location, processDownload);
                return;
            }
            if (res.statusCode !== 200) {
                reject(new Error('cannot download ' + url));
                return;
            }
            const writer = fs.createWriteStream(target);
            writer.on('error', reject);
            writer.on('close', function() { resolve(true); });
            res.pipe(writer);
        }
    });
}

module.exports = {
    bindingPath: bindingRoot + '/' + buildModuleName(versionInfo) + '.node',
    bindingRoot,
    buildModuleName,
    downloadIfNeeded,
    versionInfo,
};
