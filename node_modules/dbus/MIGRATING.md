# Migrating

Many core APIs changed betwen v0.2.21 and v1.0.0. This document describes how
to upgrade your application or library to use the new APIs when upgrading to
dbus 1.0.0.


## Clients

Migrating node applications and libraries that use this module as a DBus client.

### Getting a bus

In version 1.0.0, you no longer need to instantiate an instance of DBus in
order to get a Bus instance.

v0.2.21:

```
// v0.2.21
var DBus = require('dbus');
var dbus = new DBus();
var bus = dbus.getBus('session');
```

v1.0.0:

```
// v1.0.0
var DBus = require('dbus');
var bus = DBus.getBus('session');
```

### Calling a method

In version 1.0.0, calling a method on a DBus service uses a common node
callback pattern where the first parameter is an error and the second is the
result.

v0.2.21:

```
// v0.2.21
interface.Add.timeout = 1000;
interface.Add.error = function(err) {
  // handle error
};
interface.Add.finish = function(result) {
  assert(result === 3);
};
interface.Add(1, 2);
```

v1.0.0:

```
// v1.0.0
interface.Add(1, 2, { timeout: 1000 }, function(err, result) {
  if (err) {
    // handle error
  }

  assert(result === 3);
});
```

Timeout may be omitted if it is not needed.

```
// v1.0.0
interface.Add(1, 2, function(err, result) {
  if (err) {
    // handle error
  }

  assert(result === 3);
});
```


## Services

Migrating node applications and libraries that use this module to create DBus
services.

### Creating a service

In version 1.0.0, you no longer need to instantiate an instance of DBus in
order to get a Service instance.

v0.2.21:

```
// v0.2.21
var DBus = require('dbus');
var dbus = new DBus();
var service = dbus.registerService('session', 'test.dbus.TestService');
```

v1.0.0:

```
// v1.0.0
var DBus = require('dbus');
var service = DBus.registerService('session', 'test.dbus.TestService');
```

### Responding to a method

In v1.0.0, methods use a more typical node callback pattern where an error is
the first parameter and a result is the second parameter.

v0.2.21:

```
// v0.2.21
service.addMethod('MyMethod', { out: DBus.Define(Number) }, function(callback) {
  callback(3);
});
```

v1.0.0:

```
// v1.0.0
service.addMethod('MyMethod', { out: DBus.Define(Number) }, function(callback) {
  callback(null, 3); // return the result as the second parameter
});
```

### Throwing an error from a method

In v1.0.0, errors can include both the DBus name and a message. Previously,
they could only include the DBus name.

v0.2.21:

```
// v0.2.21
service.addMethod('MyMethod', { out: DBus.Define(Number) }, function(callback) {
  callback(new Error('test.dbus.TestService.Error');
});
```

v1.0.0:

```
// v1.0.0
service.addMethod('MyMethod', { out: DBus.Define(Number) }, function(callback) {
  callback(new DBus.Error('test.dbus.TestService.Error', 'Human-readable error message'));
});
```

Using a standard error is still possible, and defaults to
[DBUS_ERROR_FAILED][dbuserror].

```
// v1.0.0
service.addMethod('MyMethod', { out: DBus.Define(Number) }, function(callback) {
  // Error name defaults to the generic 'org.freedesktop.DBus.Error.Failed'
  callback(new Error('Human-readable error message')); 
});
```

### Responding to a property

In v1.0.0, properties use a more typical node callback pattern where an error
is the first parameter and a result is the second parameter.

v0.2.21:

```
// v0.2.21
service.addProperty('MyProperty', {
  type: DBus.Define(Number),
  getter: function(callback) {
    callback(3);
  }
});
```

v1.0.0:

```
// v1.0.0
service.addProperty('MyProperty', {
  type: DBus.Define(Number),
  getter: function(callback) {
    callback(null, 3); // Return the result as the second parameter.
  }
});
```

### Throwing an error from a property

In v1.0.0, errors can include both the DBus name and a message. Previously,
they could only include the DBus name.

v0.2.21:

```
// v0.2.21
service.addProperty('MyProperty', { 
  type: DBus.Define(Number),
  getter: function(callback) {
    callback(new Error('test.dbus.TestService.Error');
  }
});
```

v1.0.0:

```
// v1.0.0
service.addProperty('MyProperty', {
  type: DBus.Define(Number),
  getter: function(callback) {
    callback(new DBus.Error('test.dbus.TestService.Error', 'Human-readable error message'));
  }
});
```

Using a standard error is still possible, and defaults to
[DBUS_ERROR_FAILED][dbuserror].

```
// v1.0.0
service.addProperty('MyProperty', {
  type: DBus.Define(Number),
  getter: function(callback) {
    // Error name defaults to the generic 'org.freedesktop.DBus.Error.Failed'
    callback(new Error('Human-readable error message')); 
  }
});
```

[dbuserror]: https://dbus.freedesktop.org/doc/api/html/group__DBusProtocol.html#gabb62fd6340d0787fbd56ff8dd2f326c7
