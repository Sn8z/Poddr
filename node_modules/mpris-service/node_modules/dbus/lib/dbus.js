"use strict";

var _dbus = require('../build/Release/dbus.node');

var Utils = require('./utils');
var Bus = require('./bus');
var Service = require('./service');

var busMap = {};
var serviceMap = {};

var enabledSignal = false;

// Dispatch events to service
_dbus.setObjectHandler(function(uniqueName, sender, objectPath, interfaceName, member, message, args) {

	for (var hash in serviceMap) {
		var service = serviceMap[hash];

		if (service.bus.connection.uniqueName != uniqueName)
			continue;

		// Fire event
		var newArgs = [ 'request' ].concat(Array.prototype.slice.call(arguments));
		service.emit.apply(service, newArgs);

		break;
	}
});

var DBus = module.exports = function(opts) {
	var self = this;

	self._dbus = _dbus;
	self.signalHandlers = {};
};

DBus.Define = Utils.Define;
DBus.Signature = Utils.Signature;

DBus.prototype.getBus = function(busName) {
	var self = this;

	// Return bus existed
	if (busMap[busName])
		return busMap[busName];

	var bus = new Bus(self, busName);
	busMap[busName] = bus;

	return bus;
};

DBus.prototype.parseIntrospectSource = function(source) {

	return _dbus.parseIntrospectSource.apply(this, [ source ]);
};

DBus.prototype.enableSignal = function() {
	var self = this;

	if (!enabledSignal) {
		enabledSignal = true;

		_dbus.setSignalHandler(function(uniqueName) {

			if (self.signalHandlers[uniqueName]) {
				var args = [ 'signal' ].concat(Array.prototype.slice.call(arguments));

				self.signalHandlers[uniqueName].emit.apply(self.signalHandlers[uniqueName], args);
			}
		});
	}
};

DBus.prototype.addSignalFilter = function(bus, sender, objectPath, interfaceName, callback) {

	// Initializing signal if it wasn't enabled before
	if (!bus.signalEnable) {
		bus.signalEnable = true;
		_dbus.addSignalFilter(bus.connection, 'type=\'signal\'');
	}

	_dbus.addSignalFilter(bus.connection, 'type=\'signal\',sender=\'' + sender + '\',interface=\'' + interfaceName + '\',path=\'' + objectPath + '\'');

	process.nextTick(function() {
		if (callback)
			callback();
	});
};

DBus.prototype.registerService = function(busName, serviceName) {
	var self = this;

	var _serviceName = serviceName || null;

	if (serviceName) {

		// Return bus existed
		var serviceHash = busName + ':' + _serviceName;
		if (serviceMap[serviceHash])
			return serviceMap[serviceHash];
	}

	// Get a connection
	var bus = self.getBus(busName);

	if (!serviceName)
		_serviceName = bus.connection.uniqueName;

	// Create service
	var service = new Service(bus, _serviceName);
	serviceMap[serviceHash] = service;

	if (serviceName) {
		process.nextTick(function() {
			self._requestName(bus, _serviceName);
		});
	}

	return service;
};

DBus.prototype._requestName = function(bus, serviceName) {

	_dbus.requestName(bus.connection, serviceName);
};

DBus.prototype._sendMessageReply = function(message, value, type) {

	_dbus.sendMessageReply(message, value, type);
};

DBus.prototype._sendErrorMessageReply = function(message, name, msg) {

	_dbus.sendErrorMessageReply(message, name, msg);
};

DBus.prototype.callMethod = function() {

	_dbus.callMethod.apply(this, Array.prototype.slice.call(arguments));
};

DBus.prototype.setMaxMessageSize = function(bus, size) {
	_dbus.setMaxMessageSize(bus.connection, size);
};
