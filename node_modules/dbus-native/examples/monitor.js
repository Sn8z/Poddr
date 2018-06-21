const dbus = require('../index');

//var conn = dbus.createConnection({socket: '/var/run/dbus/system_bus_socket'});
var conn = dbus.createConnection();

conn.message({
  type: 1,
  serial: 1,
  path: '/org/freedesctop/DBus',
  destination: 'org.freedesktop.DBus',
  interface: 'org.freedesktop.DBus',
  member: 'Hello'
});

conn.message({
  path: '/org/freedesctop/DBus',
  destination: 'org.freedesktop.DBus',
  interface: 'org.freedesktop.DBus',
  member: 'AddMatch',
  signature: 's',
  body: ["type='signal'"]
});

conn.message({
  path: '/org/freedesctop/DBus',
  destination: 'org.freedesktop.DBus',
  interface: 'org.freedesktop.DBus',
  member: 'AddMatch',
  signature: 's',
  body: ["type='method_call'"]
});

conn.message({
  path: '/org/freedesctop/DBus',
  destination: 'org.freedesktop.DBus',
  interface: 'org.freedesktop.DBus',
  member: 'AddMatch',
  signature: 's',
  body: ["type='method_return'"]
});

conn.on('message', function(msg) {
  if (!msg.body) return;
  //console.log(JSON.stringify(msg, 0, 4)); //TODO: dbus-monitor pretty-print
});
