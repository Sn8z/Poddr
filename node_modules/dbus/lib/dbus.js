"use strict";

var _dbus = require('../build/Release/dbus.node');

var Utils = require('./utils');
var Bus = require('./bus');
var Service = require('./service');
var Error = require('./error');

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
};

DBus.Define = Utils.Define;
DBus.Signature = Utils.Signature;
DBus.Error = Error;

DBus.getBus = function(busName) {
	return new Bus(_dbus, DBus, busName);
}

/* Deprecated */
DBus.prototype.getBus = function(busName) {
	return DBus.getBus(busName);
};

DBus.signalHandlers = {};

DBus.enableSignal = function() {
	if (!enabledSignal) {
		enabledSignal = true;

		_dbus.setSignalHandler(function(uniqueName) {

			if (DBus.signalHandlers[uniqueName]) {
				var args = [ 'signal' ].concat(Array.prototype.slice.call(arguments));

				DBus.signalHandlers[uniqueName].emit.apply(DBus.signalHandlers[uniqueName], args);
			}
		});
	}
};

DBus.registerService = function(busName, serviceName) {
	var self = this;

	var _serviceName = serviceName || null;

	if (serviceName) {

		// Return bus existed
		var serviceHash = busName + ':' + _serviceName;
		if (serviceMap[serviceHash])
			return serviceMap[serviceHash];
	}

	// Get a connection
	var bus = DBus.getBus(busName);

	if (!serviceName)
		_serviceName = bus.connection.uniqueName;

	// Create service
	var service = new Service(bus, _serviceName);
	serviceMap[serviceHash] = service;

	if (serviceName) {
		DBus._requestName(bus, _serviceName);
	}

	return service
};

/* Deprecated */
DBus.prototype.registerService = function(busName, serviceName) {
	return DBus.registerService(busName, serviceName);
}

DBus._requestName = function(bus, serviceName) {
	_dbus.requestName(bus.connection, serviceName);
};
