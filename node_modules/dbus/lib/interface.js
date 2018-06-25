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

Object.defineProperty(Interface.prototype, 'connected', {
	get: function() {
		return this.bus.connected;
	}
});

Interface.prototype.init = function(callback) {
	var self = this;

	// Initializing methods
	for (var methodName in self.object['method']) {

		self[methodName] = (function(method, signature) {

			return function() {
				var allArgs = Array.prototype.slice.call(arguments);
				var interfaceIn = self.object.method[method].in;
				var dbusArgs = allArgs.slice(0, interfaceIn.length);
				var restArgs = allArgs.slice(interfaceIn.length);
				var options = restArgs[0];
				var callback = restArgs[1];

				if (typeof options === 'function') {
					// No options were specified; only a callback.
					callback = options;
					options = {};
				}

				if (!options) {
					options = {};
				}
				if (!callback) {
					callback = function() {};
				}
				var timeout = options.timeout || -1;
				var handler = this[method].finish || null
				var error = this[method].error || null

				process.nextTick(function() {
					if (!self.connected) {
						callback(new Error('Bus is no longer connected'));
						return;
					}

					try {
						self.bus.callMethod(self.bus.connection,
							self.serviceName,
							self.objectPath,
							self.interfaceName,
							method,
							signature,
							timeout,
							dbusArgs,
							callback);
					} catch(e) {
						callback(e);
					}
				});
			};
		})(methodName, self.object['method'][methodName]['in'].join('') || '');
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

	if (!self.connected) {
		process.nextTick(function() {
			callback(new Error('Bus is no longer connected'));
		});
		return;
	}

	var propSig = self.object['property'][propertyName].type;

	self.bus.callMethod(self.bus.connection,
		self.serviceName,
		self.objectPath,
		'org.freedesktop.DBus.Properties',
		'Set',
		{ type: 'ssv', concrete_type: 'ss' + propSig },
		-1,
		[ self.interfaceName, propertyName, value ],
		function(err) {

			if (callback)
				callback(err);
		});
};

Interface.prototype.getProperty = function(propertyName, callback) {
	var self = this;

	if (!self.connected) {
		process.nextTick(function() {
			callback(new Error('Bus is no longer connected'));
		});
		return;
	}

	self.bus.callMethod(self.bus.connection,
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

	if (!self.connected) {
		process.nextTick(function() {
			callback(new Error('Bus is no longer connected'));
		});
		return;
	}

	self.bus.callMethod(self.bus.connection,
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
