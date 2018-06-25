var DBus = require('../');

var bus = DBus.getBus('session');

bus.getInterface('nodejs.dbus.ExampleService', '/nodejs/dbus/ExampleService', 'nodejs.dbus.ExampleService.Interface1', function(err, iface) {

	iface.on('pump', function(count) {
		console.log(count);
	});

});
