const dbus = require('../../index');

dbus
  .createServer(function(conn) {
    conn.on('message', function(msg) {
      if (msg.serial) {
        msg.serial += 1;
      } else {
        msg.serial = 1;
      }
      conn.message(msg);
    });
    conn.message({ interface: 'yes' });
  })
  .listen(3333);
