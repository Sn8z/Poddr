"use strict";

var util = require('util');
var events = require('events');

var Interface = module.exports = function(bus, serviceName, objectPath, interfaceName, obj) {
	var self = this;

	self.bus = bus;
	self.serviceName = serviceName;
	self.objectPath = objectPath;
	self.interfaceName = interfaceName;
	self.object = obj;
};

util.inherits(Interface, events.EventEmitter);

Interface.prototype.init = function(callback) {
	var self = this;

	// Initializing methods
	for (var methodName in self.object['method']) {

		self[methodName] = (function(method, signature) {

			return function() {
				var args = Array.prototype.slice.call(arguments);
				var timeout = this[method].timeout || -1;
				var handler = this[method].finish || null
				var error = this[method].error || null

				process.nextTick(function() {

					try {
						self.bus.dbus.callMethod(self.bus.connection,
							self.serviceName,
							self.objectPath,
							self.interfaceName,
							method,
							signature,
							timeout,
							args,
							function(err, result) {

								if (err)
									return error ? error(err) : null;

								if (handler) {
									handler(result);
									handler = null;
								}
							});
					} catch(e) {
						if (error) {
							error(e);
							error = null;
						}
					}
				});

				this[method].timeout = -1;
				this[method].finish = null;
				this[method].error = null;

			};
		})(methodName, self.object['method'][methodName]['in'].join('') || '');
		self[methodName].timeout = -1;
		self[methodName].finish = null;
		self[methodName].error = null;

	}

	// Initializing signal handler
	var signals = Object.keys(self.object['signal']);
	if (signals.length) {
		self.bus.registerSignalHandler(self.serviceName, self.objectPath, self.interfaceName, self, function() {

			if (callback)
				process.nextTick(callback);
		});

		return;
	}

	if (callback)
		process.nextTick(callback);
};

Interface.prototype.setProperty = function(propertyName, value, callback) {
	var self = this;

	self.bus.dbus.callMethod(self.bus.connection,
		self.serviceName,
		self.objectPath,
		'org.freedesktop.DBus.Properties',
		'Set',
		'ssv',
		-1,
		[ self.interfaceName, propertyName, value ],
		function(err) {

			if (callback)
				callback(err);
		});
};

Interface.prototype.getProperty = function(propertyName, callback) {
	var self = this;

	self.bus.dbus.callMethod(self.bus.connection,
		self.serviceName,
		self.objectPath,
		'org.freedesktop.DBus.Properties',
		'Get',
		'ss',
		10000,
		[ self.interfaceName, propertyName ],
		function(err, value) {

			if (callback)
				callback(err, value);
		});
};

Interface.prototype.getProperties = function(callback) {
	var self = this;

	self.bus.dbus.callMethod(self.bus.connection,
		self.serviceName,
		self.objectPath,
		'org.freedesktop.DBus.Properties',
		'GetAll',
		's',
		-1,
		[ self.interfaceName ],
		function(err, value) {

			if (callback)
				callback(err, value);
		});
};
