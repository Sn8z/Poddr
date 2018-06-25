"use strict";

var util = require('util');
var events = require('events');
var Interface = require('./interface');
var DBusError = require('./error');

var Bus = module.exports = function(_dbus, DBus, busName) {
	var self = this;

	self._dbus = _dbus;
	self.DBus = DBus;
	self.name = busName;
	self.signalHandlers = {};
	self.signalEnable = false;
	self.interfaces = {};

	switch(busName) {
	case 'system':
		self.connection = _dbus.getBus(0);
		break;

	case 'session':
		self.connection = _dbus.getBus(1);
		break;
	}

	self.on('signal', function(uniqueBusName, sender, objectPath, interfaceName, signalName, args) {

		if (objectPath == '/org/freedesktop/DBus/Local' &&
			interfaceName == 'org.freedesktop.DBus.Local' &&
			signalName == 'Disconnected') {

			self.reconnect();

			return;
		}

		var signalHash = objectPath + ':' + interfaceName;

		if (self.signalHandlers[signalHash]) {
			var args = [ signalName ].concat(args);

			var interfaceObj = self.signalHandlers[signalHash];
			interfaceObj.emit.apply(interfaceObj, args);
		}
	});

	// Register signal handler of this connection
	self.DBus.signalHandlers[self.connection.uniqueName] = self;
	self.DBus.enableSignal();
};

util.inherits(Bus, events.EventEmitter);

Object.defineProperty(Bus.prototype, 'connected', {
	get: function() {
		return this.connection !== null;
	}
});

Bus.prototype.disconnect = function(callback) {
	var self = this;

	delete self.DBus.signalHandlers[self.connection.uniqueName];

	self._dbus.releaseBus(self.connection);

	self.connection = null;

	if (callback)
		process.nextTick(callback);
};

Bus.prototype.reconnect = function(callback) {
	var self = this;

	delete self.DBus.signalHandlers[self.connection.uniqueName];

	self._dbus.releaseBus(self.connection);

	switch(self.name) {
	case 'system':
		self.connection = self._dbus.getBus(0);
		break;

	case 'session':
		self.connection = self._dbus.getBus(1);
		break;
	}
	
	self.DBus.signalHandlers[self.connection.uniqueName] = self;

	// Reregister signal handler
	for (var hash in self.interfaces) {
		var iface = self.interfaces[hash];

		self.registerSignalHandler(iface.serviceName, iface.objectPath, iface.interfaceName, iface);
	}

	if (callback)
		process.nextTick(callback);
};

Bus.prototype.introspect = function(serviceName, objectPath, callback) {
	var self = this;

	if (!self.connected) {
		process.nextTick(function() {
			callback(new Error('Bus is no longer connected'));
		});
		return;
	}

	// Getting scheme of specific object
	self.callMethod(self.connection,
		serviceName,
		objectPath,
		'org.freedesktop.DBus.Introspectable',
		'Introspect',
		'',
		10000,
		[],
		function(err, introspect) {

			var obj = self._parseIntrospectSource(introspect);
			if (!obj) {
				if (callback)
					callback(new Error('No introspectable'));

				return;
			}

			if (callback)
				callback(err, obj);
		});
};

Bus.prototype._parseIntrospectSource = function(source) {
	return this._dbus.parseIntrospectSource.apply(this, [ source ]);
};

Bus.prototype.getInterface = function(serviceName, objectPath, interfaceName, callback) {
	var self = this;

	if (self.interfaces[serviceName + ':' + objectPath + ':' +interfaceName]) {
		if (callback)
			process.nextTick(function() {
				callback(null, self.interfaces[serviceName + ':' + objectPath + ':' +interfaceName]);
			});

		return;
	}

	self.introspect(serviceName, objectPath, function(err, obj) {
		if (err) {
			if (callback)
				callback(err);

			return;
		}

		if (!(interfaceName in obj)) {
			if (callback)
				callback(new Error('No such interface'));

			return;
		}

		// Create a interface object based on introspect
		var iface = new Interface(self, serviceName, objectPath, interfaceName, obj[interfaceName]);
		iface.init(function() {

			self.interfaces[serviceName + ':' + objectPath + ':' +interfaceName] = iface;

			if (callback)
				callback(null, iface);
		});
	});
};

Bus.prototype.registerSignalHandler = function(serviceName, objectPath, interfaceName, interfaceObj, callback) {
	var self = this;

	self.getUniqueServiceName(serviceName, function (err, uniqueName) {
		// Make a hash
		var signalHash = objectPath + ':' + interfaceName;
		self.signalHandlers[signalHash] = interfaceObj;

		// Register interface signal handler
		self.addSignalFilter(serviceName, objectPath, interfaceName, callback);
	});
};

Bus.prototype.setMaxMessageSize = function(size) {
	this._dbus.setMaxMessageSize(this.connection, size || 1024000);
};

Bus.prototype.getUniqueServiceName = function(serviceName, callback) {
	var self = this;

	self.callMethod(self.connection,
		'org.freedesktop.DBus',
		'/',
		'org.freedesktop.DBus',
		'GetNameOwner',
		's',
		-1,
		[serviceName],
		function(err, uniqueName) {
			callback(err, uniqueName);
		});
}

Bus.prototype.addSignalFilter = function(sender, objectPath, interfaceName, callback) {
	var self = this;

	// Initializing signal if it wasn't enabled before
	if (!self.signalEnable) {
		self.signalEnable = true;
		self._dbus.addSignalFilter(self.connection, 'type=\'signal\'');
	}

	self._dbus.addSignalFilter(self.connection, 'type=\'signal\',sender=\'' + sender + '\',interface=\'' + interfaceName + '\',path=\'' + objectPath + '\'');

	process.nextTick(function() {
		if (callback)
			callback();
	});
};

Bus.prototype._sendMessageReply = function(message, value, type) {
	this._dbus.sendMessageReply(message, value, type);
};

Bus.prototype._sendErrorMessageReply = function(message, name, msg) {
	this._dbus.sendErrorMessageReply(message, name, msg);
};

function createError(name, message) {
	return new DBusError(name, message);
}

Bus.prototype.callMethod = function() {
	var args = Array.prototype.slice.call(arguments);
	args.push(createError);
	this._dbus.callMethod.apply(this, args);
};

