const dbus = require('../../index');

var bus = dbus.sessionBus();

var destination = 'vasya.pupkin';
bus.invoke(
  {
    path: '/0/1',
    destination: destination,
    interface: 'org.vasya.pupkin.reverser',
    member: 'reverse',
    signature: 's',
    body: ['does it really work?']
  },
  function(err, res) {
    console.log(res);
  }
);
