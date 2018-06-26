var Player = require('..');

var player = Player({
	name: 'nodejs',
	identity: 'Node.js media player',
	supportedUriSchemes: ['file'],
	supportedMimeTypes: ['audio/mpeg', 'application/ogg'],
	supportedInterfaces: ['player', 'playlists']
});

player.on('quit', function () {
	process.exit();
});

player.on('activatePlaylist', function (playlistId) {
	console.log('Activate playlist:', playlistId);
	player.setActivePlaylist(playlistId);
});

player.setPlaylists([
	{
		Id: player.objectPath('playlist/0'),
		Name: 'The best playlist',
		Icon: ''
	},
	{
		Id: player.objectPath('playlist/1'),
		Name: 'The wonderful playlist',
		Icon: ''
	},
	{
		Id: player.objectPath('playlist/2'),
		Name: 'The sexyiest playlist',
		Icon: ''
	},
	{
		Id: player.objectPath('playlist/3'),
		Name: 'The coolest playlist',
		Icon: ''
	}
]);