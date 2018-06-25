var withService = require('./with-service');
var tap = require('tap');
var DBus = require('../');

tap.plan(2);
withService('service.js', function(err, done) {
	if (err) throw err;

	var dbus = new DBus();
	var bus = dbus.getBus('session');

	bus.getInterface('test.dbus.TestService', '/test/dbus/TestService', 'test.dbus.TestService.Interface1', function(err, iface) {
		// With options
		iface.IntDict({ 1: 'One', 42: 'Answer' }, { timeout: 1000 }, function(err, result) {
			tap.notSame(result, null);
			tap.same(result, [1, 42]);

			done();
			bus.disconnect();
		});
	});
});
