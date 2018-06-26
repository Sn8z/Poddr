var DBus = require('../');

var dbus = new DBus();

var bus = dbus.getBus('session');

bus.getInterface('nodejs.dbus.ExampleService', '/nodejs/dbus/ExampleService', 'nodejs.dbus.ExampleService.Interface1', function(err, iface) {

	iface.Equal['timeout'] = 1000;
	iface.Equal['error'] = function(err) {
		console.log(err);
	};
	iface.Equal['finish'] = function(result) {
		console.log(result);
	};
	iface.Equal();

});
