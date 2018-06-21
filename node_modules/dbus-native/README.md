node-dbus
===========

[![Greenkeeper badge](https://badges.greenkeeper.io/sidorares/dbus-native.svg)](https://greenkeeper.io/)
D-bus protocol client and server for node.js

[![Build Status](https://secure.travis-ci.org/sidorares/dbus-native.png)](http://travis-ci.org/sidorares/dbus-native)

Installation
------------

```shell
npm install dbus-native
```
or

```shell
git clone https://github.com/sidorares/node-dbus # clone the repo
cd node-dbus
npm install # install dependencies
sudo cp examples/com.github.sidorares.dbus.Example.conf /etc/dbus-1/system.d/ # if you want to test examples/service.js
```

Usage
------

Short example using desktop notifications service

```js
var dbus = require('dbus-native');
var sessionBus = dbus.sessionBus();
sessionBus.getService('org.freedesktop.Notifications').getInterface(
    '/org/freedesktop/Notifications',
    'org.freedesktop.Notifications', function(err, notifications) {

    // dbus signals are EventEmitter events
    notifications.on('ActionInvoked', function() {
        console.log('ActionInvoked', arguments);
    });
    notifications.on('NotificationClosed', function() {
        console.log('NotificationClosed', arguments);
    });
    notifications.Notify('exampl', 0, '', 'summary 3', 'new message text', ['xxx yyy', 'test2', 'test3', 'test4'], [],  5, function(err, id) {
       //setTimeout(function() { n.CloseNotification(id, console.log); }, 4000);
    });
});
```

API
---

### Low level messaging: bus connection

`connection = dbus.createClient(options)`

options:
   - socket - unix socket path
   - port - TCP port
   - host - TCP host
   - busAddress - encoded bus address. Default is `DBUS_SESSION_BUS_ADDRESS` environment variable. See http://dbus.freedesktop.org/doc/dbus-specification.html#addresses
   - authMethods - array of authentication methods, which are attempted in the order provided (default:['EXTERNAL', 'DBUS_COOKIE_SHA1', 'ANONYMOUS'])
   - ayBuffer - boolean (default:true): if true 'ay' dbus fields are returned as buffers
   - ReturnLongjs - boolean (default:false): if true 64 bit dbus fields (x/t) are read out as Long.js objects, otherwise they are converted to numbers (which should be good up to 53 bits)
   - ( TODO: add/document option to use adress from X11 session )

connection has only one method, `message(msg)`

message fields:
   - type - methodCall, methodReturn, error or signal
   - path - object path
   - interface
   - destination
   - sender
   - member
   - serial
   - signature
   - body
   - errorName
   - replySerial

connection signals:
   - connect - emitted after successful authentication
   - message
   - error

example:

```js
var dbus = require('dbus-native');
var conn = dbus.createConnection();
conn.message({
    path:'/org/freedesktop/DBus',
    destination: 'org.freedesktop.DBus',
    'interface': 'org.freedesktop.DBus',
    member: 'Hello',
    type: dbus.messageType.methodCall
});
conn.on('message', function(msg) { console.log(msg); });
```

### Note on INT64 'x' and UINT64 't'
Long.js is used for 64 Bit support. https://github.com/dcodeIO/long.js
The following javascript types can be marshalled into 64 bit dbus fields:
   - typeof 'number' up to 53bits
   - typeof 'string' (consisting of decimal digits with no separators or '0x' prefixed hexadecimal) up to full 64bit range
   - Long.js objects (or object with compatible properties)

By default 64 bit dbus fields are unmarshalled into a 'number' (with precision loss beyond 53 bits). Use {ReturnLongjs:true} option to return the actual Long.js object and preserve the entire 64 bits.

### Links
   - http://cgit.freedesktop.org/dbus - freedesktop reference C library
   - https://github.com/guelfey/go.dbus
   - https://github.com/Shouqun/node-dbus - libdbus
   - https://github.com/Motorola-Mobility/node-dbus - libdbus
   - https://github.com/izaakschroeder/node-dbus - libdbus
   - https://github.com/agnat/node_libdbus
   - https://github.com/agnat/node_dbus - native js
   - https://github.com/cocagne/txdbus - native python + twisted
   - http://search.cpan.org/~danberr/Net-DBus-1.0.0/ (seems to be native, but requires libdbus?)
   - https://github.com/mvidner/ruby-dbus (native, sync)
   - http://www.ndesk.org/DBusSharp (C#/Mono)
   - https://github.com/lizenn/erlang-dbus/ - erlang
   - https://github.com/mspanc/dbux/ - elixir
   - http://0pointer.net/blog/the-new-sd-bus-api-of-systemd.html - Blog post about sb-bus and D-Bus in general
