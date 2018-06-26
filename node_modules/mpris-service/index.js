var DBus = require('dbus');
var events = require('events');
var util = require('util');

function Type(signature, name) {
	return { type: signature, name: name };
}
function lcfirst(str) {
	return str[0].toLowerCase()+str.substr(1);
}

function Player(opts) {
	if (!(this instanceof Player)) return new Player(opts);
	events.EventEmitter.call(this);

	var that = this;

	this.name = opts.name;
	this.identity = opts.identity;
	this.supportedUriSchemes = opts.supportedUriSchemes;
	this.supportedMimeTypes = opts.supportedMimeTypes;
	this.desktopEntry = opts.desktopEntry;

	this.supportedInterfaces = opts.supportedInterfaces || ['player'];

	this._properties = {};

	this.init();
}
util.inherits(Player, events.EventEmitter);

Player.prototype.init = function () {
	var dbus = new DBus();

	// Create a new service, object and interface
	this.serviceName = 'org.mpris.MediaPlayer2.'+this.name;
	this.service = dbus.registerService('session', this.serviceName);
	this.obj = this.service.createObject('/org/mpris/MediaPlayer2');

	// TODO: must be defined in dbus module
	this.obj.propertyInterface.addSignal('PropertiesChanged', {
		types: [Type('s', 'interface_name'), Type('a{sv}', 'changed_properties'), Type('as', 'invalidated_properties')]
	});
	this.obj.propertyInterface.update();

	// Init interfaces
	this.interfaces = {};
	this._createRootInterface();
	if (this.supportedInterfaces.indexOf('player') >= 0) {
		this._createPlayerInterface();
	}
	if (this.supportedInterfaces.indexOf('trackList') >= 0) {
		this._createTrackListInterface();
	}
	if (this.supportedInterfaces.indexOf('playlists') >= 0) {
		this._createPlaylistsInterface();
	}
};

Player.prototype.objectPath = function (subpath) {
	return '/org/node/mediaplayer/'+this.name+'/'+(subpath || '');
};

Player.prototype._addEventedProperty = function (iface, name) {
	var that = this;

	var localName = lcfirst(name);
	var currentValue = this[localName];

	Object.defineProperty(this, localName, {
		get: function () {
			return that._properties[name];
		},
		set: function (newValue) {
			that._properties[name] = newValue;

			var changed = {};
			changed[name] = newValue;
			that.obj.propertyInterface.emitSignal('PropertiesChanged', iface, changed, []);

		},
		enumerable: true,
		configurable: true
	});

	if (currentValue) {
		this[localName] = currentValue;
	}
};

Player.prototype._addEventedPropertiesList = function (iface, props) {
	for (var i = 0; i < props.length; i++) {
		this._addEventedProperty(iface, props[i]);
	}
};

/**
 * @see http://specifications.freedesktop.org/mpris-spec/latest/Media_Player.html
 */
Player.prototype._createRootInterface = function () {
	var that = this;
	var ifaceName = 'org.mpris.MediaPlayer2',
		iface = this.obj.createInterface(ifaceName);

	// Methods

	iface.addMethod('Raise', {}, function (callback) {
		that.emit('raise');
		callback();
	});
	iface.addMethod('Quit', {}, function (callback) {
		that.emit('quit');
		callback();
	});

	// Properties

	var eventedProps = ['Identity', 'Fullscreen', 'SupportedUriSchemes', 'SupportedMimeTypes'];
	this._addEventedPropertiesList(ifaceName, eventedProps);

	iface.addProperty('CanQuit', {
		type: Type('b'),
		getter: function(callback) {
			callback((typeof that.canQuit != 'undefined') ? that.canQuit : true);
		}
	});
	iface.addProperty('Fullscreen', {
		type: Type('b'),
		getter: function(callback) {
			callback(that.fulscreen || false);
		},
		setter: function (value, next) {
			if (!that.canSetFullscreen) return next();

			that.fullscreen = value;
			that.emit('fullscreen', value);
			next();
		}
	});
	iface.addProperty('CanRaise', {
		type: Type('b'),
		getter: function(callback) {
			callback((typeof that.canRaise != 'undefined') ? that.canRaise : true);
		}
	});
	iface.addProperty('CanSetFullscreen', {
		type: Type('b'),
		getter: function(callback) {
			callback((typeof that.canSetFullscreen != 'undefined') ? that.canSetFullscreen : false);
		}
	});
	iface.addProperty('HasTrackList', {
		type: Type('b'),
		getter: function(callback) {
			callback(false);
		}
	});
	iface.addProperty('Identity', {
		type: Type('s'),
		getter: function(callback) {
			callback(that.identity || '');
		}
	});
	if (this.desktopEntry) {
		// This property is optional
		iface.addProperty('DesktopEntry', {
			type: Type('s'),
			getter: function(callback) {
				callback(that.desktopEntry || '');
			}
		});
	}
	iface.addProperty('SupportedUriSchemes', {
		type: Type('as'),
		getter: function(callback) {
			callback(that.supportedUriSchemes || []);
		}
	});
	iface.addProperty('SupportedMimeTypes', {
		type: Type('as'),
		getter: function(callback) {
			callback(that.supportedMimeTypes || []);
		}
	});

	iface.update();
	this.interfaces.root = iface;
};

/**
 * @see http://specifications.freedesktop.org/mpris-spec/latest/Player_Interface.html
 */
Player.prototype._createPlayerInterface = function () {
	var that = this;
	var ifaceName = 'org.mpris.MediaPlayer2.Player',
		iface = this.obj.createInterface(ifaceName);

	// Methods
	var eventMethods = ['Next', 'Previous', 'Pause', 'PlayPause', 'Stop', 'Play'];
	var addEventMethod = function (method) {
		iface.addMethod(method, {}, function (callback) {
			that.emit(method.toLowerCase());
			callback();
		});
	};
	for (var i = 0; i < eventMethods.length; i++) {
		addEventMethod(eventMethods[i]);
	}

	iface.addMethod('Seek', { in: [ Type('x', 'Offset') ] }, function (delta, callback) {
		that.emit('seek', { delta: delta, position: that.position + delta });
		callback();
	});
	iface.addMethod('SetPosition', { in: [ Type('o', 'TrackId'), Type('x', 'Position') ] }, function (trackId, pos, callback) {
		that.emit('position', { trackId: trackId, position: pos });
		callback();
	});
	iface.addMethod('OpenUri', { in: [ Type('s', 'Uri') ] }, function (uri, callback) {
		that.emit('open', { uri: uri });
		callback();
	});

	// Signals
	iface.addSignal('Seeked', {
		types: [Type('x', 'Position')]
	});

	// Properties
	this.position = 0;

	var eventedProps = ['PlaybackStatus', 'LoopStatus', 'Rate', 'Shuffle', 'Metadata', 'Volume'];
	this._addEventedPropertiesList(ifaceName, eventedProps);

	iface.addProperty('PlaybackStatus', {
		type: Type('s'),
		getter: function(callback) {
			callback(that.playbackStatus || 'Stopped');
		}
	});
	iface.addProperty('LoopStatus', {
		type: Type('s'),
		getter: function(callback) {
			callback(that.loopStatus || 'None');
		},
		setter: function (value, next) {
			that.loopStatus = value;
			that.emit('loopStatus', value);
			next();
		}
	});
	iface.addProperty('Rate', {
		type: Type('d'),
		getter: function(callback) {
			callback(that.rate || 1);
		},
		setter: function (value, next) {
			that.rate = value;
			that.emit('rate', value);
			next();
		}
	});
	iface.addProperty('Shuffle', {
		type: Type('b'),
		getter: function(callback) {
			callback(that.shuffle || false);
		},
		setter: function (value, next) {
			that.shuffle = value;
			that.emit('shuffle', value);
			next();
		}
	});
	iface.addProperty('Metadata', {
		type: Type('a{sv}'),
		getter: function(callback) {
			callback(that.metadata || {});
		}
	});
	iface.addProperty('Volume', {
		type: Type('d'),
		getter: function(callback) {
			callback(that.volume || 1);
		},
		setter: function (value, next) {
			that.volume = value;
			that.emit('volume', value);
			next();
		}
	});
	iface.addProperty('Position', {
		type: Type('x'),
		getter: function(callback) {
			callback(that.position || 0);
		}
	});
	iface.addProperty('MinimumRate', {
		type: Type('d'),
		getter: function(callback) {
			callback(that.minimumRate || 1);
		}
	});
	iface.addProperty('MaximumRate', {
		type: Type('d'),
		getter: function(callback) {
			callback(that.maximumRate || 1);
		}
	});
	iface.addProperty('CanGoNext', {
		type: Type('b'),
		getter: function(callback) {
			callback((typeof that.canGoNext != 'undefined') ? that.canGoNext : true);
		}
	});
	iface.addProperty('CanGoPrevious', {
		type: Type('b'),
		getter: function(callback) {
			callback((typeof that.canGoPrevious != 'undefined') ? that.canGoPrevious : true);
		}
	});
	iface.addProperty('CanPlay', {
		type: Type('b'),
		getter: function(callback) {
			callback((typeof that.canPlay != 'undefined') ? that.canPlay : true);
		}
	});
	iface.addProperty('CanPause', {
		type: Type('b'),
		getter: function(callback) {
			callback((typeof that.canPause != 'undefined') ? that.canPause : true);
		}
	});
	iface.addProperty('CanSeek', {
		type: Type('b'),
		getter: function(callback) {
			callback((typeof that.canSeek != 'undefined') ? that.canSeek : true);
		}
	});
	iface.addProperty('CanControl', {
		type: Type('b'),
		getter: function(callback) {
			callback((typeof that.canControl != 'undefined') ? that.canControl : true);
		}
	});

	iface.update();
	this.interfaces.player = iface;
};

Player.prototype.seeked = function (delta) {
	this.position += delta || 0;
	this.interfaces.player.emitSignal('Seeked', this.position);
};

/**
 * @see http://specifications.freedesktop.org/mpris-spec/latest/Track_List_Interface.html
 */
Player.prototype._createTrackListInterface = function () {
	var that = this;
	var ifaceName = 'org.mpris.MediaPlayer2.TrackList',
		iface = this.obj.createInterface(ifaceName);

	this.tracks = [];

	// Methods

	iface.addMethod('GetTracksMetadata', {
		in: [ Type('ao', 'TrackIds') ],
		out: Type('aa{sv}', 'Metadata')
	}, function (trackIds, callback) {
		callback(that.tracks.filter(function (track) {
			return (trackIds.indexOf(track['mpris:trackid']) >= 0);
		}));
	});

	iface.addMethod('AddTrack', {
		in: [ Type('s', 'Uri'), Type('o', 'AfterTrack'), Type('b', 'SetAsCurrent') ]
	}, function (uri, afterTrack, setAsCurrent, callback) {
		that.emit('addTrack', {
			uri: uri,
			afterTrack: afterTrack,
			setAsCurrent: setAsCurrent
		});
		callback();
	});

	iface.addMethod('RemoveTrack', { in: [ Type('o', 'TrackId') ] }, function (trackId, callback) {
		that.emit('removeTrack', trackId);
		callback();
	});

	iface.addMethod('GoTo', { in: [ Type('o', 'TrackId') ] }, function (trackId, callback) {
		that.emit('goTo', trackId);
		callback();
	});

	// Signals

	iface.addSignal('TrackListReplaced', {
		types: [Type('ao', 'Tracks'), Type('o', 'CurrentTrack')]
	});

	iface.addSignal('TrackAdded', {
		types: [Type('a{sv}', 'Metadata'), Type('o', 'AfterTrack')]
	});

	iface.addSignal('TrackRemoved', {
		types: [Type('o', 'TrackId')]
	});

	iface.addSignal('TrackMetadataChanged', {
		types: [Type('o', 'TrackId'), Type('a{sv}', 'Metadata')]
	});

	// Properties

	iface.addProperty('Tracks', {
		type: Type('ao'),
		getter: function(callback) {
			callback(that.tracks);
		}
	});

	iface.addProperty('CanEditTracks', {
		type: Type('b'),
		getter: function(callback) {
			callback((typeof that.canEditTracks != 'undefined') ? that.canEditTracks : false);
		}
	});

	iface.update();
	this.interfaces.trackList = iface;
};

Player.prototype.getTrackIndex = function (trackId) {
	for (var i = 0; i < this.tracks.length; i++) {
		var track = this.tracks[i];

		if (track['mpris:trackid'] == trackId) {
			return i;
		}
	}

	return -1;
};

Player.prototype.getTrack = function (trackId) {
	return this.tracks[this.getTrackIndex(trackId)];
};

Player.prototype.addTrack = function (track) {
	this.tracks.push(track);

	var afterTrack = '/org/mpris/MediaPlayer2/TrackList/NoTrack';
	if (this.tracks.length > 2) {
		afterTrack = this.tracks[this.tracks.length - 2]['mpris:trackid'];
	}
	that.interfaces.playlists.emitSignal('TrackAdded', afterTrack);
};

Player.prototype.removeTrack = function (trackId) {
	var i = this.getTrackIndex(trackId);
	this.tracks.splice(i, 1);

	that.interfaces.playlists.emitSignal('TrackRemoved', trackId);
};

/**
 * @see http://specifications.freedesktop.org/mpris-spec/latest/Playlists_Interface.html
 */
Player.prototype._createPlaylistsInterface = function () {
	var that = this;
	var ifaceName = 'org.mpris.MediaPlayer2.Playlists',
		iface = this.obj.createInterface(ifaceName);

	that.playlists = [];

	// Methods

	iface.addMethod('ActivatePlaylist', { in: [ Type('o', 'PlaylistId') ] }, function (playlistId, callback) {
		that.emit('activatePlaylist', playlistId);
		callback();
	});

	iface.addMethod('GetPlaylists', {
		in: [ Type('u', 'Index'), Type('u', 'MaxCount'), Type('s', 'Order'), Type('b', 'ReverseOrder') ],
		out: Type('a(oss)', 'Playlists')
	}, function (index, maxCount, order, reverseOrder, callback) {
		var playlists = that.playlists.slice(index, maxCount).sort(function (a, b) {
			var ret = 1;

			switch (order) {
				case 'Alphabetical':
					ret = (a.Name > b.Name) ? 1 : -1;
					break;
				//case 'CreationDate':
				//case 'ModifiedDate':
				//case 'LastPlayDate':
				case 'UserDefined':
					break;
			}

			if (reverseOrder) ret = -ret;
			return ret;
		});

		callback(playlists);
	});

	// Signals

	iface.addSignal('PlaylistChanged', {
		types: [Type('(oss)', 'Playlist')]
	});

	// Properties

	this._addEventedPropertiesList(ifaceName, ['PlaylistCount', 'ActivePlaylist']);

	iface.addProperty('PlaylistCount', {
		type: Type('u'),
		getter: function(callback) {
			callback(that.playlistCount || 0);
		}
	});

	iface.addProperty('Orderings', {
		type: Type('as'),
		getter: function(callback) {
			callback(['Alphabetical', 'UserDefined']);
		}
	});

	iface.addProperty('ActivePlaylist', {
		type: Type('(b(oss))'),
		getter: function(callback) {
			callback(that.activePlaylist || { Valid: false });
		}
	});

	iface.update();
	this.interfaces.playlists = iface;
};

Player.prototype.getPlaylistIndex = function (playlistId) {
	for (var i = 0; i < this.playlists.length; i++) {
		var playlist = this.playlists[i];

		if (playlist.Id === playlistId) {
			return i;
		}
	}

	return -1;
};

Player.prototype.setPlaylists = function (playlists) {
	this.playlists = playlists;
	this.playlistCount = playlists.length;

	var that = this;
	this.playlists.forEach(function (playlist) {
		that.interfaces.playlists.emitSignal('PlaylistChanged', playlist);
	});
};

Player.prototype.setActivePlaylist = function (playlistId) {
	var i = this.getPlaylistIndex(playlistId);

	this.activePlaylist = {
		Valid: (i >= 0) ? true : false,
		Playlist: this.playlists[i]
	};
};

module.exports = Player;
