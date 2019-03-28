const app = require("electron").app;
const contextMenu = require("electron-context-menu");

module.exports = function() {
  contextMenu({
    saveImageAs: true,
    labels: {
      cut: "Cut",
      copy: "Copy",
      paste: "Paste",
      save: "Save Image",
      saveImageAs: "Save Image As…",
      copyLink: "Copy Link",
      copyImageAddress: "Copy Image Address",
      inspect: "Poddr DevTools"
    }
  });

  if (process.platform == "darwin") {
    const Menu = require("electron").Menu;
    var menuTemplate = [
      {
        label: "Poddr",
        submenu: [
          {
            label: "Quit",
            accelerator: "Command+Q",
            click: function() {
              app.quit();
            }
          }
        ]
      },
      {
        label: "Edit",
        submenu: [
          { label: "Cut", accelerator: "CmdOrCtrl+X", selector: "cut:" },
          { label: "Copy", accelerator: "CmdOrCtrl+C", selector: "copy:" },
          { label: "Paste", accelerator: "CmdOrCtrl+V", selector: "paste:" },
          {
            label: "Select All",
            accelerator: "CmdOrCtrl+A",
            selector: "selectAll:"
          }
        ]
      }
    ];
    Menu.setApplicationMenu(Menu.buildFromTemplate(menuTemplate));
  }
};
