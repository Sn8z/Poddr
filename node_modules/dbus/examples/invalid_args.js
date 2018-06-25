var DBus = require('../');

var bus = DBus.getBus('session');

bus.getInterface('nodejs.dbus.ExampleService', '/nodejs/dbus/ExampleService', 'nodejs.dbus.ExampleService.Interface1', function(err, iface) {
	iface.Equal({ timeout: 1000 }, function(err, result) {
		if (err) {
			return console.log(err);
		}

		console.log(result);
	});
});
