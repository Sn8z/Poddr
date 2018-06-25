var tap = require('tap');
var DBus = require('../');

tap.plan(1);

var client = DBus.getBus('session');

var timeout = setTimeout(function() {
	tap.fail('Should have disconnected by now');
	process.exit();
}, 1000);
timeout.unref();

tap.ok('This is a dummy test. The real test is whether the tap.fail gets called on the timeout.');
setTimeout(function() {
	client.disconnect();
}, 50);

setTimeout(function() {
	var service = DBus.registerService('session', 'test.dbus.TestService');
	service.createObject('/test/dbus/TestService');
	setImmediate(function() {
		service.disconnect();
	});
}, 100);
