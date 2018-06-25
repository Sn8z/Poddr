var tap = require('tap');
var DBus = require('../');

tap.plan(1);

var service = DBus.registerService('session', 'test.dbus.TestService');
var object = service.createObject('/test/dbus/TestService');
var iface = object.createInterface('test.dbus.TestService.Interface1');
iface.addSignal('Test', { types: [DBus.Define(String)] });
iface.update()

setTimeout(function() {
	tap.throws(function() {
    var objectd = service.createObject('/test/dbus/TestService');
    var ifaced = objectd.createInterface('test.dbus.TestService.Interface1');
    ifaced.addSignal('Test', { types: [DBus.Define(String)] });
    ifaced.update();
	})

	service.disconnect()
}, 100);
