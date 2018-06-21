const dbus = require('../../index');

var count = 0;
const conn = dbus.createConnection({ port: 3333, handshake: 'none' });
conn.on('message', function(msg) {
  if (msg.serial) {
    msg.serial += 1;
  } else {
    msg.serial = 1;
  }
  conn.message(msg);
  count++;
});

setInterval(function() {
  console.log(count);
  count = 0;
}, 1000);
