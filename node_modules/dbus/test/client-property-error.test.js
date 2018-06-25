var withService = require('./with-service');
var tap = require('tap');
var DBus = require('../');

tap.plan(4);
withService('service.js', function(err, done) {
	if (err) throw err;

	var bus = DBus.getBus('session');

	bus.getInterface('test.dbus.TestService', '/test/dbus/TestService', 'test.dbus.TestService.ErrorInterface', function(err, iface) {
		iface.getProperty('ErrorProperty', function(err, value) {
			tap.notSame(err, null);
			tap.same(value, null);
			tap.match(err.message, /from.*service/);
			tap.type(err, DBus.Error);
			done();
			bus.disconnect();
		});
	});
});
