var DBus = require('../');

var bus1 = DBus.getBus('session');

bus1.getInterface('nodejs.dbus.ExampleService', '/nodejs/dbus/ExampleService', 'nodejs.dbus.ExampleService.Interface1', function(err, iface) {

	iface.Hello({ timeout: 1000 }, function(result) {
		console.log(result);
	});

});

var bus2 = DBus.getBus('session');

bus2.getInterface('nodejs.dbus.ExampleService', '/nodejs/dbus/ExampleService', 'nodejs.dbus.ExampleService.Interface1', function(err, iface) {

	iface.Hello({ timeout: 1000 }, function(result) {
		console.log(result);
	});

});

