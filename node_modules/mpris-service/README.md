# mpris-service

Node.js implementation for the MPRIS D-Bus Interface Specification to create a mediaplayer service.

Docs: http://specifications.freedesktop.org/mpris-spec/latest/

```js
var Player = require('mpris-service');

var player = Player({
	name: 'nodejs',
	identity: 'Node.js media player',
	supportedUriSchemes: ['file'],
	supportedMimeTypes: ['audio/mpeg', 'application/ogg'],
	supportedInterfaces: ['player']
});
```

Implemented interfaces:
* [`org.mpris.MediaPlayer2`](http://specifications.freedesktop.org/mpris-spec/latest/Media_Player.html)
* [`org.mpris.MediaPlayer2.Player`](http://specifications.freedesktop.org/mpris-spec/latest/Player_Interface.html)
* [`org.mpris.MediaPlayer2.TrackList`](http://specifications.freedesktop.org/mpris-spec/latest/Track_List_Interface.html)
* [`org.mpris.MediaPlayer2.Playlists`](http://specifications.freedesktop.org/mpris-spec/latest/Playlists_Interface.html)

Examples are available in [`examples/`](https://github.com/emersion/mpris-service/tree/master/examples).

## Default interface

```js
player.on('quit', function () {
	process.exit();
});
```

Events:
* `raise`
* `quit`
* `fullscreen`

Properties:
* `identity`
* `name`
* `supportedUriSchemes`
* `supportedMimeTypes`
* `desktopEntry`

## Player

```js
// See http://www.freedesktop.org/wiki/Specifications/mpris-spec/metadata/
player.metadata = {
	'mpris:trackid': player.objectPath('track/0'),
	'mpris:length': 60 * 1000 * 1000, // In microseconds
	'mpris:artUrl': 'https://pbs.twimg.com/profile_images/378800000822867536/3f5a00acf72df93528b6bb7cd0a4fd0c.jpeg',
	'xesam:title': 'Best song',
	'xesam:album': 'Best album',
	'xesam:artist': 'Best singer'
};

player.playbackStatus = 'Playing';
```

Events:
* `next`
* `previous`
* `pause`
* `playpause`
* `stop`
* `play`
* `seek`
* `position`
* `open`
* `loopStatus`
* `rate`
* `shuffle`
* `volume`

Properties:
* `playbackStatus`
* `loopStatus`
* `rate`
* `shuffle`
* `volume`
* `metadata`
* `minimumRate`
* `maximumRate`
* `canGoNext`
* `canGoPrevious`
* `canPlay`
* `canPause`
* `canSeek`
* `canControl`

Methods:
* `seeked(offset)`

## TrackList

Events:
* `addTrack`
* `removeTrack`
* `goTo`

Properties:
* `tracks`
* `canEditTracks`

Methods:
* `addTrack(track)`
* `removeTrack(trackId)`

## Playlists

Events:
* `activatePlaylist`

Properties:
* `playlists`
* `activePlaylist`

Methods:
* `setPlaylists(playlists)`
* `setActivePlaylist(playlistId)`
