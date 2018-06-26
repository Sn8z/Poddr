var DBus = require('../');

var dbus = new DBus();

var bus = dbus.getBus('session');

bus.getInterface('nodejs.dbus.ExampleService', '/nodejs/dbus/ExampleService', 'nodejs.dbus.ExampleService.Interface1', function(err, iface) {

	iface.SendObject['timeout'] = 1000;
	iface.SendObject['finish'] = function(result) {
		console.log(result);
	};

	iface.SendObject({
		name: 'Fred',
		email: 'cfsghost@gmail.com'
	});

	// Blank object
	iface.SendObject({});

	// Testing method with no return value
	iface.Dummy['timeout'] = 1000;
	iface.Dummy['finish'] = function() {
		console.log('Dummy');
	};
	iface.Dummy();

	// Testing method with complex dictionary object
	iface.GetContacts['timeout'] = 1000;
	iface.GetContacts['finish'] = function(contacts) {
		console.log(contacts);
	};
	iface.GetContacts();

	// Error handling
	iface.SendObject['finish'] = function(ret) {
		console.log(ret);
	};
	iface.SendObject('Wrong arguments');
});
