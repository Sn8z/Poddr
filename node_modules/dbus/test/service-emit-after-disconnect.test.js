var tap = require('tap');
var DBus = require('../');

tap.plan(2);

var service = DBus.registerService('session', 'test.dbus.TestService');
var object = service.createObject('/test/dbus/TestService');
var iface = object.createInterface('test.dbus.TestService.Interface1');

iface.addSignal('Test', { types: [DBus.Define(String)] });

var timeout = setTimeout(function() {
	tap.fail('Should have disconnected by now');
	process.exit();
}, 1000);
timeout.unref();

tap.ok('This is a dummy test. The real test is whether the tap.fail gets called on the timeout.');
setTimeout(function() {
	service.disconnect();
}, 50);
setTimeout(function() {
	tap.throws(function() {
		iface.emitSignal('Test', 'test');
	}, /no.*connected/, 'Emit throws an error after disconnect');
}, 100);
