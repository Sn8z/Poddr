var DBus = require('../');

// Create a new service, object and interface
var service = DBus.registerService('session', 'test.dbus.DynamicTestService');
var obj = service.createObject('/test/dbus/DynamicTestService');

var subobjs = {};

process.on('message', function(msg) {
	if (msg.type === 'add') {
		var value = msg.value.toString();
		var subobj = service.createObject('/test/dbus/DynamicTestService/subs/' + value);
		var subiface = subobj.createInterface('test.dbus.DynamicTestService.DynamicInterface1');
		subiface.addProperty('Value', {
			type: DBus.Define(String),
			getter: function(callback) {
				callback(null, value);
			}
		});
		subiface.update();
		subobjs[value] = subobj;
		process.send({ type: 'add', value: value });
	}
	else if (msg.type === 'remove') {
		var value = msg.value.toString();
		if (subobjs[value]) {
			var subobj = subobjs[value];
			service.removeObject(subobj);
			delete subobjs[value];
			process.send({ type: 'remove', value: value });
		}
		else {
			process.send({ type: 'remove', value: value });
		}
	}
	else if (msg.message === 'done') {
		service.disconnect();
		process.removeAllListeners('message');
	}
});

process.send({ message: 'ready' });
