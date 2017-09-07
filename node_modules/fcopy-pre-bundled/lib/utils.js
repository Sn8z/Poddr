'use strict';
const fs = require('fs');

module.exports = {
    makeError,
    validate,
    withFileDescriptors,
};

function validate(dest, src) {
    if (!dest) { return makeError(2, 'ENOENT', "Invalid path ''"); }
    if (!src) { return makeError(2, 'ENOENT', "Invalid path ''"); }
    if (dest === src) { return makeError(1, 'EPERM', 'Cannot copy, identical path'); }
    return null;
}

function makeError(errno, code, message) {
    const err = new Error(code + ': ' + message);
    err.errno = errno;
    err.code = code;
    return err;
}

function withFileDescriptors(binding) {
    if (!binding) { throw new Error('missing binding function'); }
    return function fcopy(src, dest, opts, callback) {
        let fdsrc, fddest, outerr, outresult;
        openFiles(src, dest, opts, sendFile);

        function cleanup(ex_, result_) {
            outerr = ex_;
            outresult = result_;
            closeFiles(fdsrc, fddest, respond);
        }

        function sendFile(ex, _fdsrc, _fddest) {
            fdsrc = _fdsrc;
            fddest = _fddest;
            if (ex) {
                callback(ex);
                return;
            }
            binding(fdsrc, fddest, cleanup);
        }

        function respond() {
            if (outerr) {
                callback(outerr);
            } else {
                callback(null, outresult);
            }
        }
    };
}

function openFiles(src, dest, opts, callback) {
    fs.open(src, 'r', function openSrc(ex, fdsrc) {
        if (ex) { callback(ex); return; }
        fs.open(dest, 'w', opts.mode, function openDest(ex2, fddest) {
            if (ex2) {
                fs.close(fdsrc, function() {});
                callback(ex2);
                return;
            }
            callback(null, fdsrc, fddest);
        });
    });
}

function closeFiles(src, dest, fn) {
    let i = 0;
    const done = () => i++ && fn();
    if (src) { fs.close(src, done); }
    if (dest) { fs.close(dest, done); }
    if (!src && !dest) { fn(); }
}
