"use strict";

var util = require('util');
var events = require('events');
var Interface = require('./interface');

var Bus = module.exports = function(dbus, busName) {
	var self = this;

	self.dbus = dbus;
	self.name = busName;
	self.signalHandlers = {};
	self.signalEnable = false;
	self.interfaces = {};

	switch(busName) {
	case 'system':
		self.connection = dbus._dbus.getBus(0);
		break;

	case 'session':
		self.connection = dbus._dbus.getBus(1);
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
	self.dbus.signalHandlers[self.connection.uniqueName] = self;
	self.dbus.enableSignal();
};

util.inherits(Bus, events.EventEmitter);

Bus.prototype.reconnect = function(callback) {
	var self = this;

	delete self.dbus.signalHandlers[self.connection.uniqueName];

	self.dbus._dbus.releaseBus(self.connection);

	switch(self.name) {
	case 'system':
		self.connection = self.dbus._dbus.getBus(0);
		break;

	case 'session':
		self.connection = self.dbus._dbus.getBus(1);
		break;
	}
	
	self.dbus.signalHandlers[self.connection.uniqueName] = self;

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

	// Getting scheme of specific object
	self.dbus.callMethod(self.connection,
		serviceName,
		objectPath,
		'org.freedesktop.DBus.Introspectable',
		'Introspect',
		'',
		10000,
		[],
		function(err, introspect) {

			var obj = self.dbus.parseIntrospectSource(introspect);
			if (!obj) {
				if (callback)
					callback(new Error('No introspectable'));

				return;
			}

			if (callback)
				callback(err, obj);
		});
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
		self.dbus.addSignalFilter(self, serviceName, objectPath, interfaceName, callback);
	});
};

Bus.prototype.setMaxMessageSize = function(size) {
	var self = this;

	self.dbus.setMaxMessageSize(self, size || 1024000);
};

Bus.prototype.getUniqueServiceName = function(serviceName, callback) {
	var self = this;

	self.dbus.callMethod(self.connection,
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
