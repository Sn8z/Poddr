var withService = require('./with-service');
var tap = require('tap');
var DBus = require('../');

tap.plan(3);
withService('service.js', function(err, done) {
	if (err) throw err;

	var dbus = new DBus();
	var bus = dbus.getBus('session');

	bus.getInterface('test.dbus.TestService', '/test/dbus/TestService', 'test.dbus.TestService.Interface1', function(err, iface) {
		// With options
		iface.Object({ one: 'One', two: [1,2] }, { timeout: 1000 }, function(err, result) {
			tap.notSame(result, null);
			tap.equal(result.one, 'One');
			tap.same(result.two, [1, 2]);

			done();
			bus.disconnect();
		});
	});
});
