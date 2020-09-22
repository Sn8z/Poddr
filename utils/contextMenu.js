const { Menu } = require('electron');
const electron = require('electron');

module.exports = function (mainWindow) {

	const application = {
		label: 'Application',
		submenu: [
			{
				label: 'About Application',
				role: 'about'
			},
			{
				type: 'separator'
			},
			{
				label: 'Quit',
				accelerator: 'Command+Q',
				click: () => {
					electron.app.quit();
				}
			}
		]
	};

	const edit = {
		label: 'Edit',
		submenu: [
			{
				label: 'Cut',
				accelerator: 'CmdOrCtrl+X',
				role: 'cut'
			},
			{
				label: 'Copy',
				accelerator: 'CmdOrCtrl+C',
				role: 'copy'
			},
			{
				label: 'Paste',
				accelerator: 'CmdOrCtrl+V',
				role: 'paste'
			},
			{
				label: 'Select All',
				accelerator: 'CmdOrCtrl+A',
				role: 'selectAll'
			}
		]
	};
	const template = [application, edit];
	Menu.setApplicationMenu(Menu.buildFromTemplate(template));

	const ctxMenu = Menu.buildFromTemplate(edit.submenu);

	mainWindow.webContents.on('context-menu', (event, params) => {
		ctxMenu.popup();
	});
};
