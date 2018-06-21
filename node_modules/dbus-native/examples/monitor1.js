const dbus = require('../index');

var bus = dbus.systemBus();
bus.invoke({
  member: 'AddMatch',
  signature: 's',
  body: ["type='signal'"]
});
bus.invoke({
  member: 'AddMatch',
  signature: 's',
  body: ["type='method_call'"]
});
bus.invoke({
  member: 'AddMatch',
  signature: 's',
  body: ["type='method_return'"]
});
