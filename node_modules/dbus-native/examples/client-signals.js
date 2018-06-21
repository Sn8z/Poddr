const dbus = require('../index');

/*
	This example shows how to query a DBus service and listen for its signals.
	Since we're acting only as a client, there is not need to request a name: we don't need to register a service
	against the bus (but we could!), so we only act as a client.

	NOTE: this file is made to query the service that is exposed in the file 'server-signals.js', so be sure to
	start it first (node server-signals.js in another terminal should be enough)
)
*/

// This is the DBus service we will query (server-signals.js)
const targetServiceName = 'com.dbus.native.signals';

// This is the service's interface we will query
const targetIfaceName = targetServiceName; // note that is it equal to the service name, but this is not mandatory at all

// This is the service's DBus object path that we will query for the properties
const targetObjectPath = `/${targetServiceName.replace(/\./g, '/')}`;

// First, connect to the session bus (works the same on the system bus, it's just less permissive)
const sessionBus = dbus.sessionBus();

// Check the connection was successful
if (!sessionBus) {
  throw new Error('Could not connect to the DBus session bus.');
}

// First, we must query the bus for the desired DBus service:
const targetService = sessionBus.getService(targetServiceName);

// Then we must query it's interface, this is callback-based
targetService.getInterface(targetObjectPath, targetIfaceName, (err, iface) => {
  // we need to check for error
  if (err || !iface) {
    console.error(
      `Could not query interface '${targetIfaceName}', the error was: ${err}`
        ? err
        : '(no error)'
    );
    process.exit(1);
  }

  /*
		Here, 'iface' represents the service's interface. It is made an event emitter, so to listen to signals, we
		just have to do like any other signals: on('signalName')
	*/
  iface.on('Tick', date => {
    console.log(`Signal 'Tick' received! The date is: '${date}'`);
  });

  /*
		Here we listen for the second signal.
	*/
  iface.on('Rand', randomNumber => {
    console.log(`We've got our random number: ${randomNumber}`);
  });
});
