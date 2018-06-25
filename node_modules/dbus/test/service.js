var DBus = require('../');

// Create a new service, object and interface
var service = DBus.registerService('session', 'test.dbus.TestService');
var obj = service.createObject('/test/dbus/TestService');

// Create interface

var iface1 = obj.createInterface('test.dbus.TestService.Interface1');

iface1.addMethod('NoArgs', { out: DBus.Define(String) }, function(callback) {
	callback(null, 'result!');
});

iface1.addMethod('Add', { in: [DBus.Define(Number), DBus.Define(Number)], out: DBus.Define(Number) }, function(n1, n2, callback) {
	callback(null, n1 + n2);
});

iface1.addMethod('Object', { in: [DBus.Define(Object)], out: DBus.Define(Object) }, function(obj, callback) {
	callback(null, obj);
});

iface1.addMethod('IntDict', { in: [{ type: 'a{ys}' }], out: { type: 'ay' }}, function (dict, callback) {
	callback(null, Object.keys(dict).sort());
})

iface1.addMethod('LongProcess', { out: DBus.Define(Number) }, function(callback) {
	setTimeout(function() {
		callback(null, 0);
	}, 5000).unref();
});

var author = 'Fred Chien';
iface1.addProperty('Author', {
	type: DBus.Define(String),
	getter: function(callback) {
		callback(null, author);
	},
	setter: function(value, callback) {
		author = value;

		callback();
	}
});

// Read-only property
var url = 'http://stem.mandice.org';
iface1.addProperty('URL', {
	type: DBus.Define(String),
	getter: function(callback) {
		callback(null, url);
	}
});

// Signal
var counter = 0;
iface1.addSignal('pump', {
	types: [
		DBus.Define(Number)
	]
});

iface1.update();

// Emit signal per one second
var interval = setInterval(function() {
	counter++;
	iface1.emit('pump', counter);
}, 1000);
interval.unref();

var errors = obj.createInterface('test.dbus.TestService.ErrorInterface');

errors.addMethod('ThrowsError', { out: DBus.Define(Number) }, function(callback) {
	setTimeout(function() {
		callback(new Error('This is an error thrown from the service'));
	}, 100);
});

errors.addMethod('ThrowsCustomError', { out: DBus.Define(Number) }, function(callback) {
	setTimeout(function() {
		var error = new DBus.Error('test.dbus.TestService.Error', 'This is an error thrown from the service');
		callback(error);
	}, 100);
});

errors.addProperty('ErrorProperty', {
	type: DBus.Define(String),
	getter: function(callback) {
		callback(new Error('This is an error thrown from the service'));
	}
});

errors.update();

// Create second interface
var iface2 = obj.createInterface('test.dbus.TestService.Interface2');

iface2.addMethod('Hello', { out: DBus.Define(String) }, function(callback) {
	callback(null, 'Hello There!');
});

iface2.update();

process.send({ message: 'ready' });
process.on('message', function(msg) {
	if (msg.message === 'done') {
		clearInterval(interval);
		service.disconnect();
		process.removeAllListeners('message');
	}
});
