var DBus = require('../');

var bus = DBus.getBus('session');

bus.getInterface('nodejs.dbus.ExampleService', '/nodejs/dbus/ExampleService', 'nodejs.dbus.ExampleService.Interface1', function(err, iface) {

	iface.SendObject({
		name: 'Fred',
		email: 'cfsghost@gmail.com'
	}, { timeout: 1000 }, function(err, result) {
		console.log(result);
	});

	// Blank object
	iface.SendObject({}, { timeout: 1000 }, function(err, result) {
	});

	// Testing method with no return value
	iface.Dummy({ timeout: 1000 }, function(err) {
		console.log('Dummy');
	});

	// Testing method with complex dictionary object
	iface.GetContacts({ timeout: 1000 }, function(err, contacts) {
		console.log(contacts);
	});

	// Error handling
	iface.SendObject('Wrong arguments', function(err, result) {
		if (err) {
			return console.log(err);
		}

		console.log(result);
	});
});
