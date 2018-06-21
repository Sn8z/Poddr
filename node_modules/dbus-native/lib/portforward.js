const net = require('net');
const abs = require('abstract-socket');
const hexy = require('hexy').hexy;

var address = process.env.DBUS_SESSION_BUS_ADDRESS;
var m = address.match(/abstract=([^,]+)/);

net
  .createServer(function(s) {
    var buff = '';
    var connected = false;
    var cli = abs.createConnection(`\0${m[1]}`);
    s.on('data', function(d) {
      if (connected) {
        cli.write(d);
      } else {
        buff += d.toString();
      }
    });
    setTimeout(function() {
      console.log('CONNECTED!');
      connected = true;
      cli.write(buff);
    }, 100);
    cli.pipe(s);

    cli.on('data', function(b) {
      console.log(hexy(b, { prefix: 'from client ' }));
    });
    s.on('data', function(b) {
      console.log(hexy(b, { prefix: 'from server ' }));
    });
  })
  .listen(3334, function() {
    console.log(
      'Server started. connect with DBUS_SESSION_BUS_ADDRESS=tcp:host=127.0.0.1,port=3334'
    );
  });
