const dbus = require('../index');

/*
	This test file's purpose is to show how to write a simple, basic DBus service with this library.
	In order to do that, we connect to the session bus and create a DBus service exposing some functions,
	some properties and some signals.

	For instance you can use `gdbus` to introspect a service and make function calls.
	- introspect: `gdbus introspect -e -d com.dbus.native.return.types -o /com/dbus/native/return/types`
	- make a method call: `gdbus introspect -e -d com.dbus.native.return.types -o /com/dbus/native/return/types -m com.dbus.native.return.types.FunctionName`
*/

const serviceName = 'com.dbus.native.basic.service'; // our DBus service name
/*
	The interface under which we will expose our functions (chose to be the same as the service name, but we can
	choose whatever name we want, provided it respects the rules, see DBus naming documentation)
*/
const interfaceName = serviceName;
/*
	The object pat hthat we want to expose on the bus. Here we chose to have the same path as the service (and
	interface) name, with the dots replaced by slashes (because objects path must be on the form of UNIX paths)
	But again, we could chose anything. This is just a demo here.
*/
const objectPath = `/${serviceName.replace(/\./g, '/')}`;

// First, connect to the session bus (works the same on the system bus, it's just less permissive)
const sessionBus = dbus.sessionBus();

// Check the connection was successful
if (!sessionBus) {
  throw new Error('Could not connect to the DBus session bus.');
}

/*
	Then request our service name to the bus.
	The 0x4 flag means that we don't want to be queued if the service name we are requesting is already
	owned by another service ;we want to fail instead.
*/
sessionBus.requestName(serviceName, 0x4, (err, retCode) => {
  // If there was an error, warn user and fail
  if (err) {
    throw new Error(
      `Could not request service name ${serviceName}, the error was: ${err}.`
    );
  }

  // Return code 0x1 means we successfully had the name
  if (retCode === 1) {
    console.log(`Successfully requested service name "${serviceName}"!`);
    proceed();
  } else {
    /* Other return codes means various errors, check here
	(https://dbus.freedesktop.org/doc/api/html/group__DBusShared.html#ga37a9bc7c6eb11d212bf8d5e5ff3b50f9) for more
	information
	*/
    throw new Error(
      `Failed to request service name "${
        serviceName
      }". Check what return code "${retCode}" means.`
    );
  }
});

// Function called when we have successfully got the service name we wanted
function proceed() {
  // First, we need to create our interface description (here we will only expose method calls)
  var ifaceDesc = {
    name: interfaceName,
    methods: {
      // Simple types
      SayHello: ['', 's', [], ['hello_sentence']],
      GiveTime: ['', 's', [], ['current_time']],
      Capitalize: ['s', 's', ['initial_string'], ['capitalized_string']]
    },
    properties: {
      Flag: 'b',
      StringProp: 's'
    },
    signals: {
      Rand: ['i', 'random_number']
    }
  };

  // Then we need to create the interface implementation (with actual functions)
  var iface = {
    SayHello: function() {
      return 'Hello, world!';
    },
    GiveTime: function() {
      return new Date().toString();
    },
    Capitalize: function(str) {
      return str.toUpperCase();
    },
    Flag: true,
    StringProp: 'initial string',
    emit: function() {
      // no nothing, as usual
    }
  };

  // Now we need to actually export our interface on our object
  sessionBus.exportInterface(iface, objectPath, ifaceDesc);

  // Say our service is ready to receive function calls (you can use `gdbus call` to make function calls)
  console.log('Interface exposed to DBus, ready to receive function calls!');

  setInterval(() => {
    var rand = Math.round(Math.random() * 100);
    if (rand > 75) {
      iface.emit('Rand', Math.round(Math.random() * 100));
    }
  }, 2000);
}
