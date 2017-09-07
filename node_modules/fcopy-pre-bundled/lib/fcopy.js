'use strict';
const utils = require('./utils');
const NOFALLBACK = !!process.env.FCOPY_NOFALLBACK;
const NOOPTS = {};
let copier;

module.exports = function fcopy(src, dest, opts, callback) {
    if (copier === undefined) {
        copier = findCopier();
    }

    if (typeof opts === 'function') {
        callback = opts;
        opts = undefined;
    }

    if (!opts) {
        opts = NOOPTS;
    }

    const ex = utils.validate(src, dest, opts);
    if (callback) {
        if (ex) {
            setImmediate(function cb() { callback(ex); });
        } else {
            copier(src, dest, opts, callback);
        }
        return;
    }

    /* eslint-disable consistent-return */
    return new Promise(function fcopy(resolve, reject) {
        if (ex) {
            reject(ex);
        } else {
            copier(src, dest, opts, function copyResult(err) {
                if (err) {
                    reject(err);
                } else {
                    resolve();
                }
            });
        }
    });
};

module.exports.setCopier = function setCopier(value) {
    copier = value;
};

function findCopier() {
    try {
        const bindingResolver = require('./bindings.js');
        const binding = require(bindingResolver.bindingPath);
        return require('./copiers/sendfile')(binding);
    } catch (ex) {
        if (NOFALLBACK) { throw ex; }
    }

    return require('./copiers/fallback');
}
