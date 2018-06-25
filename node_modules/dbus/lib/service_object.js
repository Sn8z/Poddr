"use strict";

var Utils = require('./utils');

var ServiceInterface = require('./service_interface');

var ServiceObject = module.exports = function(service, objectPath) {
	var self = this;

	self.service = service;
	self.path = objectPath;
	self.interfaces = {};
	self.introspection = null;

	// Initializing introspectable interface
	self.introspectableInterface = self.createInterface('org.freedesktop.DBus.Introspectable');
	self.introspectableInterface.addMethod('Introspect', { out: Utils.Define(String, 'data') }, function(callback) {
		self.updateIntrospection();
		callback(null, self.introspection);
	});
	self.introspectableInterface.update();

	// Initializing property interface
	self.propertyInterface = self.createInterface('org.freedesktop.DBus.Properties');
	self.propertyInterface.addMethod('Get', {
		in: [
			Utils.Define(String, 'interface_name'),
			Utils.Define(String, 'property_name')
		],
		out: Utils.Define('Auto', 'value')
	}, function(interfaceName, propName, callback) {
		var iface = self['interfaces'][interfaceName];
		if (!iface) {
			callback(new Error('Doesn\'t support such property'));
			return;
		}

		if (!iface.getProperty(propName, callback))
			callback(new Error('Doesn\'t support such property'));
	});

	self.propertyInterface.addMethod('Set', {
		in: [
			Utils.Define(String, 'interface_name'),
			Utils.Define(String, 'property_name'),
			Utils.Define('auto', 'value')
		]
	}, function(interfaceName, propName, value, callback) {
		var iface = self['interfaces'][interfaceName];
		if (!iface) {
			callback(new Error('Doesn\'t support such property'));
			return;
		}

		if (!iface.setProperty(propName, value, callback))
			callback(new Error('Doesn\'t support such property'));
	});

	self.propertyInterface.addMethod('GetAll', {
		in: [
			Utils.Define(String, 'interface_name')
		],
		out: Utils.Define(Object, 'properties')
	}, function(interfaceName, callback) {
		var iface = self['interfaces'][interfaceName];
		if (!iface) {
			callback(new Error('Doesn\'t have any properties'));
			return;
		}

		iface.getProperties(function(err, props) {
			callback(err, props);
		});
	});
	
	self.propertyInterface.addSignal('PropertiesChanged', {
		types: [Utils.Define(String, 'interface_name'), Utils.Define(Object, 'changed_properties'), Utils.Define(Array, 'invalidated_properties')]
	});
	
	self.propertyInterface.update();
};

ServiceObject.prototype.createInterface = function(interfaceName) {
	var self = this;

	if (!self.interfaces[interfaceName])
		self.interfaces[interfaceName] = new ServiceInterface(self, interfaceName);

	self.interfaces[interfaceName].update();

	return self.interfaces[interfaceName];
};

ServiceObject.prototype.updateIntrospection = function() {
	var self = this;
	var i;

	var introspection = [
		'<!DOCTYPE node PUBLIC "-//freedesktop//DTD D-BUS Object Introspection 1.0//EN"',
		'"http://www.freedesktop.org/standards/dbus/1.0/introspect.dtd">',
		'<node name="' + self.path + '">'
	];

	for (var interfaceName in self.interfaces) {
		var iface = self.interfaces[interfaceName];
		introspection.push(iface.introspection);
	}

	var childNodes = self.buildChildNodes();

	for (i = 0; i < childNodes.length; i++) {
		introspection.push('<node name="' + childNodes[i] + '"/>');
	}
	introspection.push('</node>');

	self.introspection = introspection.join('\n');
};

ServiceObject.prototype.buildChildNodes = function() {
	var self = this;

	function unique(arr) {
		var t = {};
		var i;
		for (i = 0; i < arr.length; i++) {
			t[arr[i]] = true;
		}

		return Object.keys(t);
	}

	var prefix = self.path + '/';
	var allKeys = Object.keys(self.service.objects);
	var childKeys = allKeys.filter(function(key) {
		return key.substr(0, prefix.length) == prefix
		    && key.length > prefix.length;
	});
	var unprefixedChildKeys = childKeys.map(function(key) {
		return key.substr(prefix.length);
	});
	var childNodes = unprefixedChildKeys.map(function(key) {
		return key.split('/')[0];
	});
	var uniqueChildNodes = unique(childNodes);

	return uniqueChildNodes;
};
