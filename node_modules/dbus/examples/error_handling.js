var DBus = require('../');

var bus = DBus.getBus('session');

bus.getInterface('nodejs.dbus.ExampleService', '/nodejs/dbus/ExampleService', 'nodejs.dbus.ExampleService.Interface1', function(err, iface) {

	iface.MakeError({ timeout: 1000 }, function(err, result) {
		if (err) {
			console.log(err);
			return;
		}

		console.log(result);
	});
});
