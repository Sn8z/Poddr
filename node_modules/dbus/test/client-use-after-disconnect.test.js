var tap = require('tap');
var DBus = require('../');

var bus = DBus.getBus('session');

tap.plan(11);

var timeout = setTimeout(function() {
	tap.fail('Should have disconnected by now');
	process.exit();
}, 1000);
timeout.unref();

tap.ok('This is a dummy test. The real test is whether the tap.fail gets called on the timeout.');

bus.getInterface('org.freedesktop.DBus', '/', 'org.freedesktop.DBus', function(err, iface) {
	setTimeout(function() {
		bus.disconnect();
	}, 50);

	setTimeout(function() {
		iface.getProperty('Test', function(err, value) {
			tap.type(err, Error);
			tap.match(err.message, /no.*connected/, 'getProperty returns the correct error');
		});
		iface.setProperty('Test', 'Value', function(err) {
			tap.type(err, Error);
			tap.match(err.message, /no.*connected/, 'setProperty returns the correct error');
		});
		iface.getProperties(function(err, values) {
			tap.type(err, Error);
			tap.match(err.message, /no.*connected/, 'getProperties returns the correct error');
		});
		iface.NameHasOwner('Test', function(err, result) {
			tap.type(err, Error);
			tap.match(err.message, /no.*connected/, 'call returns the correct error');
		});
		bus.getInterface('org.freedesktop.DBus', '/obj', 'org.freedesktop.DBus', function(err, iface) {
			tap.type(err, Error);
			tap.match(err.message, /no.*connected/, 'getInterface returns the correct error');
		});
	}, 100);
});
