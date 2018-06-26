var DBus = require('../');

var dbus = new DBus();

var bus = dbus.getBus('session');

bus.setMaxMessageSize(5000000);
