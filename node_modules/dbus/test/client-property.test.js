var withService = require('./with-service');
var tap = require('tap');
var DBus = require('../');

tap.plan(5);
withService('service.js', function(err, done) {
	if (err) throw err;

	var bus = DBus.getBus('session');

	bus.getInterface('test.dbus.TestService', '/test/dbus/TestService', 'test.dbus.TestService.Interface1', function(err, iface) {
		iface.getProperty('Author', function(err, value) {
			tap.equal(value, 'Fred Chien');

			iface.setProperty('Author', 'Douglas Adams', function(err) {
				iface.getProperty('Author', function(err, value) {
					tap.equal(value, 'Douglas Adams');

					iface.getProperty('URL', function(err, value) {
						tap.equal(value, 'http://stem.mandice.org');

						iface.getProperties(function(err, props) {
							tap.equal(props.Author, 'Douglas Adams');
							tap.equal(props.URL, 'http://stem.mandice.org');
							done();
							bus.disconnect();
						});
					});
				});
			}); 
		});
	});
});
