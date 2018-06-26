"use strict";

var util = require('util');
var events = require('events');
var ServiceObject = require('./service_object');

var Service = module.exports = function(bus, serviceName) {
	var self = this;

	self.bus = bus;
	self.serviceName = serviceName;
	self.objects = {};

	self.on('request', function(uniqueName, sender, objectPath, interfaceName, member, message, args) {
		var iface = self.objects[objectPath]['interfaces'][interfaceName];
		if (!iface)
			return;

		iface.call.apply(iface, [ member, message, args ]);
	});
};

util.inherits(Service, events.EventEmitter);

Service.prototype.createObject = function(objectPath) {
	var self = this;

	if (!self.objects[objectPath])
		self.objects[objectPath] = new ServiceObject(self, objectPath);

	// Register object
	self.bus.dbus._dbus.registerObjectPath(self.bus.connection, objectPath);

	return self.objects[objectPath];
};
