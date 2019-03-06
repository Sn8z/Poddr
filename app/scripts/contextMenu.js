const contextMenu = require('electron-context-menu');

(function () {
    contextMenu({
        saveImageAs: true,
        labels: {
            cut: 'Cut',
            copy: 'Copy',
            paste: 'Paste',
            save: 'Save Image',
            saveImageAs: 'Save Image As…',
            copyLink: 'Copy Link',
            copyImageAddress: 'Copy Image Address',
            inspect: 'Poddr DevTools'
        }
    });
}());

