# node-dbus  
node-dbus is a D-Bus binding for Node.js.

[![Build Status](https://travis-ci.org/Shouqun/node-dbus.svg?branch=master)](https://travis-ci.org/Shouqun/node-dbus)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](#license)

## Installation

```bash
$ npm install dbus
```

## How To Build
To build, do: `node-gyp configure build` or `npm install`.

## Migrating to version 1.0

The API changed between version 0.2.21 and version 1.0.0. See
[migrating][migrating] for information on how to migrate your application to
the new API.

## Dependencies

### General

* **Node-gyp**

	```bash
	$ npm install -g node-gyp
	```

	[https://www.npmjs.com/package/node-gyp](https://www.npmjs.com/package/node-gyp)

* **libdbus**

	```bash
	$ sudo apt-get install libdbus-1-dev
	```

	or equivalent for your system

* **glib2.0**

	```bash
	$ sudo apt-get install libglib2.0-dev
	```
	
	or equivalent for your system

### MacOS with MacPorts/HomeBrew

* **Node-gyp**

	```bash
	$ npm install -g node-gyp
	```

	[https://www.npmjs.com/package/node-gyp](https://www.npmjs.com/package/node-gyp)

* **libdbus**  
	MacPorts: `$ sudo port install pkg-config dbus`
	HomeBrew: `$ sudo brew install pkg-config dbus`

* **glib2.0**  
	MacPorts: `$ sudo port install glib2`
	HomeBrew: `$ sudo brew install glib`

## Getting Started

Best way to get started is by looking at the examples. After the build:

1. Navigate to `path/to/dbus/examples` folder
2. Run `node service.js &`
3. Run  `node hello.js`

Work your way through other examples to explore supported functionality.

## Note on systems without X11

If no X server is running, the module fails when attempting to obtain a D-Bus
connection at `DBus.getBus()`. This can be remedied by setting two environment
variables manually (the actual bus address might be different):

```javascript
process.env.DISPLAY = ':0';
process.env.DBUS_SESSION_BUS_ADDRESS = 'unix:path=/run/dbus/system_bus_socket';
```

## API


### DBus

The root object of this module.

#### `DBus.getBus(busName)`

* busName `<string>`

Connect to a bus. `busName` must be either `"system"` to connect to the system
bus or `"session"` to connect to the session bus.

Returns a `Bus`.

```javascript
var bus = DBus.getBus('session');
```

#### `DBus.registerService(busName, serviceName)`

* busName `<string>`
* serviceName `<string>`

Register a service on a specific bus. This allows the caller to create a DBus
service.

`busName` must be either `"system"` to create the service on the system bus, or
`"session"` to create the service on the session bus. _Note: the system bus
often has security requirements that need to be met before the service can be
registered._

Returns a `Service`.

```javascript
var service = DBus.registerService('session', 'com.example.Library');
```

#### *DEPRECATED* `new DBus()`

Create a new DBus instance.

```javascript
var DBus = require('dbus')
var dbus = new DBus()
```

#### *DEPRECATED* `DBus.prototype.getBus(busName)`

Use `DBus.getBus(busName)`.

#### *DEPRECATED* `DBus.prototype.registerService(busName, serviceName)`

Use `DBus.registerService(busName, serviceName)`


### Bus

An active connection to one of DBus' buses.

#### `Bus.prototype.getInterface(serviceName, objectPath, interfaceName, callback)`

* serviceName `<string>` - The well-known name of the service that owns the object.
* objectPath `<string>` - The path of the object.
* interfaceName `<string>` - Which of the object's interfaces to retrieve.
* callback `<function>`

Get an existing object's interface from a well-known service.

Once retrieved, `callback` will be called with either an error or with an
`Interface`.

```javascript
bus.getInterface('com.example.Library', '/com/example/Library/authors/DAdams', 'com.example.Library.Author1', function(err, interface) {
    if (err) {
        ...
    }

    // Do something with the interface
});
```

#### `Bus.prototype.disconnect()`

Disconnect from DBus. This disconnection makes it so that Node isn't kept
running based on this active connection. It also makes this bus, and all of its
children (interfaces that have been retrieved, etc.) unusable.


### Interface

#### `Interface.prototype.getProperty(propertyName, callback)`

* propertyName `<string>` - The name of the property to get.
* callback `<function>`

Get the value of a property.

Once retrieved `callback` will be called with either an error or with the value
of the property.

```javascript
interface.getProperty('Name', function(err, name) {
});
```

#### `Interface.prototype.setProperty(propertyName, value, callback)`

* propertyName `<string>` - The name of the property to get.
* value `<any>` - The value of the property to set.
* callback `<function>`

Set the value of a property.

Once set `callback` will be called with either an error or nothing.

```javascript
interface.setProperty('Name', 'Douglas Adams', function(err) {
});
```

#### `Interface.prototype.getProperties(callback)`

* callback `<function>`

Get the value of all of the properties of the interface.

Once retrieved `callback` will be called with either an error or with an object
where the keys are the names of the properties, and the values are the values
of those properties.

```javascript
interface.getProperties(function(err, properties) {
    console.log(properties.Name);
});
```

#### `Interface.prototype[methodName](...args, [options], callback)`

* methodName `<string>` - The name of the method on the interface to call.
* ...args `<any>` - The arguments that must be passed to the method.
* options `<object>` - The options that can be set. This is optional.
  * options.timeout `<number>` - The number of milliseconds to wait before the
    request is timed out. This defaults to `-1`: don't time out.
* callback `<function>`

Call a method on the interface.

Once executed, `callback` will be called with either an error or with the
result of the method call.

```javascript
interface.AddBook("The Hitchhiker's Guide to the Galaxy", { timeout: 1000 }, function(err, result) {
})
```


### Service

A dbus service created by the application.

#### `Service.prototype.createObject(objectPath)`

* objectPath `<string>` - The path of the object. E.g., `/com/example/ObjectName`

Create an object that is exposed over DBus.

Returns a `ServiceObject`.

```javascript
var object = service.createObject('/com/example/Library/authors/DAdams');
```

#### `Service.prototype.removeObject(object)`

* object `<ServiceObject>` - the service object that has been created

Remove (or unexpose) an object that has been created.

```
service.removeObject(object);
```

#### `Service.prototype.disconnect()`

Disconnect from DBus. This disconnection makes it so that Node isn't kept
running based on this active connection. It also disconnects all of the objects
created by this service. 


### ServiceObject

An object that is exposed over DBus.

#### `ServiceObject.prototype.createInterface(interfaceName)`

* interfaceName `<string>` - The name of the interface.

Create an interface on an object.

Returns a `ServiceInterface`.

```javascript
var interface = object.createInterface('com.example.Library.Author1');
```


### ServiceInterface

An interface for an object that is exposed over DBus.

#### `ServiceInterface.prototype.addMethod(method, opts, handler)`

* method `<string>` - The name of the method
* opts `<object>` - Options for the method
  * opts.in - The signature for parameters
  * opts.out - The signature for what the method returns
* handler `<function>` - The method handler

Add a method that can be called over DBus.

```javascript
interface.addMethod('AddBook', {
	in: [DBus.Define(String), DBus.Define(Number)],
	out: [DBus.Define(Number)]
}, function(name, quality, callback) {
	doSomeAsyncOperation(name, quality, function(err, result) {
		if (err) {
			return callback(err);
		}

		callback(result);
	});
});
```

#### `ServiceInterface.prototype.addProperty(name, opts)`

* name `<string>` - The name of the property
* opts `<object>`
  * opts.type - The type of the property
  * opts.getter - The function to retrieve the value
  * opts.setter - The function to set the value (optional)

Add a property that can be get, and/or optionally set, over DBus.

```javascript
interface.addProperty('BooksWritten', {
  type: DBus.Define(Number),
  getter: function(callback) {
    getNumberOfBooksForAuthor(function(err, bookCount) {
      if(err) {
        return callback(err);
      }
      callback(bookCount);
    });
  }
}

var name = 'Douglas Adams';
interface.addProperty('Name', {
  type: Dbus.Define(String),
  getter: function(callback) {
    callback(name);
  }
  setter: function(value, done) {
    name = value;
    done();
  }
}
```

#### `ServiceInterface.prototype.addSignal(name, opts)`

* name `<string>` - The name of the signal
* opts `<object>`
  * types

Create a DBus signal.

```javascript
interface.addSignal('bookCreated', {
  types: [DBus.Define(Object)]
});
```

#### `ServiceInterface.prototype.emitSignal(name, ...values)`

* name `<string>` - The name of the signal
* values `<any>` - The values to emit

Emit a signal

```javascript
interface.emit('bookCreated', { name: "The Hitchhiker's Guide to the Galaxy" })
```

#### `ServiceInterface.prototype.update()`

Save interface updates after making changes. After changes to the interface are
made (via `addMethod`, `addProperty`, and `addSignal`), `update` must be called
to ensure that other DBus clients can see the changes that were made.


### DBus.Error

A DBus-specific error

#### `new DBus.Error(name, message)`

* name `<string>` - A valid DBus Error name, according to the [specification][spec]
* message `<string>` - A human readable message

Create a new error. The name must be a valid error name.

```javascript
throw new DBus.Error('com.example.Library.Error.BookExistsError', 'The book already exists');
```

#### `dbusError.dbusName`

The DBus Error name of the error. When a DBus.Error is created, its message is
set to the human-readable error message. The `dbusName` property is set to the
name (according to the DBus Spec).


## License 

(The MIT License)

Copyright (c) 2013

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[spec]: https://dbus.freedesktop.org/doc/dbus-specification.html
[migrating]: MIGRATING.md
