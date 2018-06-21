const dbus = require('../../index');
const addrx11 = require('../../lib/address-x11');

addrx11(function(err, address) {
  var bus = dbus.sessionBus({ busAddress: address });
  var name = 'some.name';
  var iface = 'com.example.service';

  function test() {
    bus.invoke(
      {
        path: '/',
        destination: name,
        interface: iface,
        member: 'doStuff',
        signature: 's',
        body: ['does it really work?']
      },
      function(err, res) {
        console.log(err, res);
      }
    );
  }

  bus.addMatch("type='signal'");
  bus.connection.on('message', console.log);

  setInterval(test, 2000);
  test();
});
