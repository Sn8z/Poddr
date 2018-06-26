var DBus = require('../');

var dbus = new DBus();

var bus = dbus.getBus('session');

bus.getInterface('nodejs.dbus.ExampleService', '/nodejs/dbus/ExampleService', 'nodejs.dbus.ExampleService.Interface1', function(err, iface) {

	iface.Hello['timeout'] = 1000;
	iface.Hello['finish'] = function(result) {
		console.log(result);
	};
	iface.Hello();

});
