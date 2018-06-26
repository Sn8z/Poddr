var DBus = require('../');

var dbus = new DBus();

var bus1 = dbus.getBus('session');

bus1.getInterface('nodejs.dbus.ExampleService', '/nodejs/dbus/ExampleService', 'nodejs.dbus.ExampleService.Interface1', function(err, iface) {

	iface.Hello['timeout'] = 1000;
	iface.Hello['finish'] = function(result) {
		console.log(result);
	};
	iface.Hello();

});

var bus2 = dbus.getBus('session');

bus2.getInterface('nodejs.dbus.ExampleService', '/nodejs/dbus/ExampleService', 'nodejs.dbus.ExampleService.Interface1', function(err, iface) {

	iface.Hello['timeout'] = 1000;
	iface.Hello['finish'] = function(result) {
		console.log(result);
	};
	iface.Hello();

});

