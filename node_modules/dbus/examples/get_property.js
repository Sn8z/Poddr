var DBus = require('../');

var bus = DBus.getBus('session');

bus.getInterface('nodejs.dbus.ExampleService', '/nodejs/dbus/ExampleService', 'nodejs.dbus.ExampleService.Interface1', function(err, iface) {

	iface.getProperty('Author', function(err, value) {
		console.log(value);
	});

	iface.getProperty('JavaScriptOS', function(err, value) {
		console.log(value);
	});

	iface.getProperty('URL', function(err, value) {
		console.log(value);
	});

	// Get all properties
	iface.getProperties(function(err, props) {
		console.log('Properties:');
		console.log(props);
	});

});
