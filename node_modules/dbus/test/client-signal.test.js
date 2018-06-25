var withService = require('./with-service');
var tap = require('tap');
var DBus = require('../');

tap.plan(1);
withService('service.js', function(err, done) {
	if (err) throw err;

	var bus = DBus.getBus('session');

	bus.getInterface('test.dbus.TestService', '/test/dbus/TestService', 'test.dbus.TestService.Interface1', function(err, iface) {
		iface.on('pump', function() {
			tap.pass('Signal received');
			done();
			bus.disconnect();
		});
	});
});
