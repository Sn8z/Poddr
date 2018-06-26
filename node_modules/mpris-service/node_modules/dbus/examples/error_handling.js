var DBus = require('../');

var dbus = new DBus();

var bus = dbus.getBus('session');

bus.getInterface('nodejs.dbus.ExampleService', '/nodejs/dbus/ExampleService', 'nodejs.dbus.ExampleService.Interface1', function(err, iface) {

	iface.MakeError['timeout'] = 1000;
	iface.MakeError['error'] = function(err) {
		console.log(err);
	};
	iface.MakeError['finish'] = function(result) {
		console.log(result);
	};
	iface.MakeError();

});
