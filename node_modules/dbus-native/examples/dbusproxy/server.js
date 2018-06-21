const http = require('http');
const sockjs = require('sockjs');
const node_static = require('node-static');
const dbus = require('../../index');

// 1. Echo sockjs server
var sockjs_opts = {
  sockjs_url: 'https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js'
};

var sockjs_echo = sockjs.createServer(sockjs_opts);
sockjs_echo.on('connection', function(conn) {
  var dbusConn = dbus.sessionBus().connection;
  conn.on('data', function(message) {
    //conn.write(message);
    try {
      //console.log('about to parse', message)
      var o = JSON.parse(message);
      //console.log('after parse', [o]);
      try {
        dbusConn.message(o);
      } catch (ee) {
        console.log(ee);
      }
      //console.log('sent to dbus');
    } catch (e) {}
  });
  dbusConn.on('message', function(msg) {
    //console.log('GOT MESSAGE', msg);
    conn.write(JSON.stringify(msg));
    //conn.write(msg);
  });
});

// 2. Static files server
var static_directory = new node_static.Server(__dirname);

// 3. Usual http stuff
var server = http.createServer();
server.addListener('request', function(req, res) {
  static_directory.serve(req, res);
});
server.addListener('upgrade', function(req, res) {
  res.end();
});

sockjs_echo.installHandlers(server, { prefix: '/echo' });

console.log(' [*] Listening on 0.0.0.0:9999');
server.listen(9999, '0.0.0.0');
