const dbus = require('../../index');

var bus = dbus.sessionBus();
var name = 'vasya.pupkin';
bus.connection.on('message', function(msg) {
  if (
    msg.destination === name &&
    msg['interface'] === 'org.vasya.pupkin.reverser' &&
    msg.path === '/0/1'
  ) {
    var reply = {
      type: dbus.messageType.methodReturn,
      destination: msg.sender,
      replySerial: msg.serial,
      sender: name,
      signature: 's',
      body: [
        msg.body[0]
          .split('')
          .reverse()
          .join('')
      ]
    };
    bus.invoke(reply);
  }
});
bus.requestName(name, 0);
