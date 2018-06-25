var withService = require('./with-service');
var tap = require('tap');
var DBus = require('../');

tap.plan(4);
withService('service-dynamic.js', function(err, done) {
	if (err) throw err;

	var bus = DBus.getBus('session');
	var process = done.process;

	addObject(process, '1', function() {
		checkInterface(bus, '1', function(err, result) {
			tap.equal(result, true);
			checkInterface(bus, '2', function(err, result) {
				tap.equal(result, false);
				addObject(process, '2', function() {
					checkInterface(bus, '2', function(err, result) {
						tap.equal(result, true);
						removeObject(process, '2', function() {
							checkInterface(bus, '2', function(err, result) {
								tap.equal(result, false);
								done();
								bus.disconnect();
							});
						});
					});
				});
			});
		});
	});
});

function addObject(process, value, callback) {
	process.once('message', function() {
		callback();
	});
	process.send({ type: 'add', value: value });
}

function removeObject(process, value, callback) {
	process.once('message', function() {
		callback();
	});
	process.send({ type: 'remove', value: value });
}

function checkInterface(bus, value, callback) {
	value = value.toString();
	bus.getInterface('test.dbus.DynamicTestService', '/test/dbus/DynamicTestService/subs/' + value, 'test.dbus.DynamicTestService.DynamicInterface1', function(err, iface) {
		if (!err) {
			// We might have the interface cached. Let's actually
			// try to get a property.
			iface.getProperty('Value', function(err, result) {	
				if (!err) {
					return callback(null, true);
				}
				if (err instanceof DBus.Error && /UnknownMethod/.test(err.dbusName)) {
					// This object doesn't exist. We're good.
					return callback(null, false);
				}
				return callback(err);
			});
			return;
		}
		if (/interface/.test(err.message)) {
			return callback(null, false);
		}
		callback(err);
	});
}

