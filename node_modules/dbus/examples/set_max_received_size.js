var DBus = require('../');

var bus = DBus.getBus('session');

bus.setMaxMessageSize(5000000);
