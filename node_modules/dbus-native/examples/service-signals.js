const dbus = require('../index');
const inspect = require('util').inspect;

/*
	This example show how to expose signals on a DBus service, and how to emit them.
*/

const serviceName = 'com.dbus.native.signals'; // our DBus service name
/*
	The interface under which we will expose our signals (chose to be the same as the service name, but we can
	choose whatever name we want, provided it respects the rules, see DBus naming documentation)
*/
const interfaceName = serviceName;
/*
	The object path that we want to expose on the bus. Here we chose to have the same path as the service (and
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
    signals: {
      // Defines a signal whose name is 'Tick' and whose output param is: string (s)
      Tick: ['s', 'time'], // second argument is the name of the output parameters (for introspection)
      // Defines a signal whose name is 'Rand' and whose ouput param is: int32 (i)
      Rand: ['i', 'random_number']
    },
    // No methods nor properties for this example
    methods: {},
    properties: {}
  };

  // Then we need to create the interface implementation, with the 'emit' field
  var iface = {
    /*
			So what's going one here, in order for your DBus service to be able to emit signals, you must define one
			function in your interface object with name 'emit'. This should be a function which takes several
			parameters: the first parameter is the name of the signal to fire, and the rest of the parameters are the
			actual signal OUTPUT values (a signal doesn't take input parameters).

			Here we use the neat ES6 syntax, the spread operator (...), this basically says "bind the first argument in
			the variable 'signalName' and all others in 'signalOutputParams'"
		*/
    emit: function(signalName, ...signalOutputParams) {
      /*
				Now we are in the body of the 'emit()' function of the interface.
				Just to be clear: you dont NEED to put ANYTHING in this body. When you call 'bus.exportInterface()',
				for each signals that is defined in your interface description object, there will be a new 'emit'
				function created that will simply fire the signal.
				Then, after one emit function is defined for the signal, this emit's function will be called.

				So really, everything that inside this emit function serves just as debugging or logging. If you're
				only interested in emitting a signal, then all you have to do is create this emit function in the
				interface objet, and do nothing. The signal swill be emitted just fine.

				Here, we are only putting some logging to show where the signals are emitted.
			*/

      console.log(
        `Signal '${signalName}' emitted with values: ${inspect(
          signalOutputParams
        )}`
      );
    }
  };
  // Now we need to actually export our interface on our object
  sessionBus.exportInterface(iface, objectPath, ifaceDesc);

  // Say our service is ready to receive function calls (you can use `gdbus call` to make function calls)
  console.log('Interface exposed to DBus, ready to receive function calls!');

  /*
		Here we emit the 'Tick' signal every 10 seconds. As you see, emitting a signal is just calling the 'emit()'
		function of the interface object with the first parameters being the signal name, and the other paramters, the
		actual output values of the signal.
	*/
  setInterval(() => {
    iface.emit('Tick', new Date().toString());
  }, 10e3);

  /*
		Here we emit another signal, 'Rand'. As you noticed, the 'emit()' function doesn't change whether we expose
		one or several signals.
		The random here is just so that the signals are not emitted too regularly (contrary to 'Tick')
	*/
  setInterval(() => {
    var proba = Math.round(Math.random() * 100);

    if (proba > 70) {
      var randomNumber = Math.round(Math.random() * 100);
      iface.emit('Rand', randomNumber);
    }
  }, 2000);
}
