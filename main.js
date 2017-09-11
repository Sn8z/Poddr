const electron = require('electron');
const app = electron.app;
const BrowserWindow = electron.BrowserWindow;

//Global reference to window object;
var mainWindow = null;

//Quit when all windows are closed
app.on('window-all-closed', function(){
  app.quit();
});

//When app is rdy, create window
app.on('ready', function(){
  mainWindow = new BrowserWindow({
    name: "Poddr",
    width: 1200,
    height: 900,
    frame: false,
    backgroundColor: "#333333"
  });

  //Point to html file to be opened
  mainWindow.loadURL('file://' + __dirname + "/app/index.html");

  //Devtools
  mainWindow.webContents.openDevTools({detach:true});

  //Cleanup on window close
  mainWindow.on('closed', function(){
    mainWindow = null;
  });
});
