var withService = require('./with-service');
var tap = require('tap');
var DBus = require('../');

tap.plan(10);
withService('service.js', function(err, done) {
	if (err) throw err;

	var bus = DBus.getBus('session');

	bus.getInterface('test.dbus.TestService', '/test/dbus/TestService', 'test.dbus.TestService.ErrorInterface', function(err, iface) {
		iface.ThrowsError({ timeout: 1000 }, function(err, result) {
			tap.notSame(err, null);
			tap.same(result, null);
			tap.match(err.message, /from.*service/);
			tap.match(err.dbusName, 'org.freedesktop.DBus.Error.Failed');
			tap.type(err, DBus.Error);

			iface.ThrowsCustomError({ timeout: 1000 }, function(err, result) {
				tap.notSame(err, null);
				tap.same(result, null);
				tap.match(err.message, /from.*service/);
				tap.match(err.dbusName, 'test.dbus.TestService.Error');
				tap.type(err, DBus.Error);
				done();
				bus.disconnect();
			});
		});
	});
});
