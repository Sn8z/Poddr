const electron = require('electron');
const app = electron.app;
const BrowserWindow = electron.BrowserWindow;
const windowStateKeeper = require('electron-window-state');

//Global reference to window object;
var mainWindow = null;

//Quit when all windows are closed
app.on('window-all-closed', function(){
  app.quit();
});

//When app is rdy, create window
app.on('ready', function(){

  //default window size
  let mainWindowState = windowStateKeeper({
    defaultWidth: 1200,
    defaultHeight: 900
  });

  mainWindow = new BrowserWindow({
    name: "Poddr",
    width: mainWindowState.width,
    height: mainWindowState.height,
    x: mainWindowState.x,
    y: mainWindowState.y,
    frame: false,
    show: false,
    backgroundColor: "#333333",
    icon: __dirname + '/app/images/icon.png'
  });

  //add listeners to the window
  mainWindowState.manage(mainWindow);

  //when main window is ready
  mainWindow.on('ready-to-show', function() { 
    mainWindow.show(); 
    mainWindow.focus(); 
  });

  //Point to html file to be opened
  mainWindow.loadURL('file://' + __dirname + "/app/index.html");

  //Devtools
  //mainWindow.webContents.openDevTools({detach:true});

  //Cleanup on window close
  mainWindow.on('closed', function(){
    mainWindow = null;
  });
});
