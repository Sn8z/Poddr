var withService = require('./with-service');
var tap = require('tap');
var DBus = require('../');

tap.plan(2);
withService('service.js', function(err, done) {
	if (err) throw err;

	var bus = DBus.getBus('session');

	bus.getInterface('test.dbus.TestService', '/test/dbus/TestService', 'test.dbus.TestService.Interface1', function(err, iface) {
		// With options
		iface.NoArgs({ timeout: 1000 }, function(err, result) {
			tap.equal(result, 'result!');

			// Without options
			iface.NoArgs(function(err, result) {
				tap.equal(result, 'result!');
				done();
				bus.disconnect();
			});
		});
	});
});
