const dbus = require('../index');

/*
	This test file's purpose is to show example of possible return types for functions.
	In order to do that, we connect to the session bus and create a DBus service exposing
	a certain number of function calls (no signals nor properties) that you can call with
	any DBus-speaking software.

	For instance you can use `gdbus` to introspect a service and make function calls.
	- introspect: `gdbus introspect -e -d com.dbus.native.return.types -o /com/dbus/native/return/types`
	- make a method call: `gdbus introspect -e -d com.dbus.native.return.types -o /com/dbus/native/return/types -m com.dbus.native.return.types.FunctionName`
*/

const serviceName = 'com.dbus.native.return.types'; // our DBus service name
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
  var ifaceDesc;
  var iface;

  // First, we need to create our interface description (here we will only expose method calls)
  ifaceDesc = {
    name: interfaceName,
    methods: {
      // Simple types
      SayHello: ['', 's', [], ['hello_sentence']], // Takes no input and returns a single string
      GetInt16: ['', 'n', [], ['Int16_number']], // Takes no input and returns an int16 integers
      GetUInt16: ['', 'q', [], ['UInt16_number']], // Takes no input and returns an uint16 integers
      GetInt32: ['', 'i', [], ['Int32_number']], // Takes no input, returns an int32 integer
      GetUInt32: ['', 'u', [], ['UInt32_number']], // Takes no input, returns an uint32 integer
      // 64 numbers being not handled natively in Javascript, they are not yet handled by this library (WIP)
      //GetInt64: ['', 'x', [], ['Int32_number']], // Takes no input, returns an int64 integer
      //GetUInt64: ['', 't', [], ['UInt32_number']], // Takes no input, returns an uint64 integer
      GetBool: ['', 'b', [], ['Bool_value']], // Takes no input, returns a boolean
      GetDouble: ['', 'd', [], ['Double_value']], // Takes no input, returns a double
      GetByte: ['', 'y', [], ['Byte_value']], // Takes no input, returns a byte

      // Complex-types
      GetArrayOfStrings: ['y', 'as', ['nb_elems'], ['strings']], // Take a number and return an array of N strings
      // Takes no input, returns a structure with a string, an int32 and a bool
      GetCustomStruct: ['', '(sib)', [], ['struct']],
      // Takes no input, returns a dictionary (hash-table) whose keys are strings and values int32
      GetDictEntry: ['', 'a{si}', [], ['dict_entry']]
    },
    // No signals nor properties for this example
    signals: {},
    properties: {}
  };

  // Then we need to create the interface implementation (with actual functions)
  iface = {
    SayHello: function() {
      return 'Hello, world!'; // This is how to return a single string
    },
    GetInt16: function() {
      var min = -0x7fff - 1;
      var max = 0x7fff;
      return Math.round(Math.random() * (max - min) + min);
    },
    GetUInt16: function() {
      var min = 0;
      var max = 0xffff;
      return Math.round(Math.random() * (max - min) + min);
    },
    GetInt32: function() {
      var min = -0x7fffffff - 1;
      var max = 0x7fffffff;
      return Math.round(Math.random() * (max - min) + min);
    },
    GetUInt32: function() {
      var min = 0;
      var max = 0xffffffff;
      return Math.round(Math.random() * (max - min) + min);
    },
    GetBool: function() {
      return Math.random() >= 0.5 ? true : false;
    },
    GetDouble: function() {
      /*
				We are only returning a number between 0 and 1 here, but this is just for the test.
				Javascript can handle number between Number.MIN_VALUE and Number.MAX_VALUE, which are 5e-234 and 1.7976931348623157e+308 respectively.
				There would be no point in returing such big numbers for this demo, but this is perfectly okay with DBus.
			*/
      return Math.random();
    },
    GetByte: function() {
      var min = 0x00;
      var max = 0xff;
      return Math.round(Math.random() * (max - min) + min);
    },
    GetArrayOfStrings: function(n) {
      // Check that we requested a positive number of elements, and not a too big one
      if (n < 0 || n > 255) {
        // Return a DBus error to indicate a problem (shows how to send DBus errors)
        return new Error(
          'Incorrect number of elements supplied (0 < n < 256)!'
        );
      }

      var ret = [];
      while (n--) {
        ret.unshift(`String #${n}`);
      }

      return ret; // 'ret' is an array, to return an array, we simply return it
    },
    GetCustomStruct: function() {
      var min = -0x7fffffff - 1;
      var max = 0x7fffffff;
      var string =
        'Im sorry, my responses are limited, you must ask the right question.';
      var int32 = Math.round(Math.random() * (max - min) + min);
      var bool = Math.random() >= 0.5 ? true : false;

      /*
				Important note here: for the DBus type STRUCT, you need to return a Javascript ARRAY, with the field in
				the right order for the declared struct.
			*/
      return [string, int32, bool];
    },
    GetDictEntry: function() {
      var min = -0x7fffffff - 1;
      var max = 0x7fffffff;
      var key1 = 'str1';
      var key2 = 'str2';
      var key3 = 'str3';
      var i1 = Math.round(Math.random() * (max - min) + min);
      var i2 = Math.round(Math.random() * (max - min) + min);
      var i3 = Math.round(Math.random() * (max - min) + min);

      /*
				This is how DICT_ENTRIES are returned: in JS side, it's an array of arrays.
				Each of the arrays must have TWO values, the first being the key (here a string ; keys
				MUST be single types, so string, integers, double, booleans, etc.) and the second being
				the value (here, an int32 ; keys can be any type, including complex one: struct, etc.)
			*/
      return [[key1, i1], [key2, i2], [key3, i3]];
    }
  };

  // Now we need to actually export our interface on our object
  sessionBus.exportInterface(iface, objectPath, ifaceDesc);

  // Say our service is ready to receive function calls (you can use `gdbus call` to make function calls)
  console.log('Interface exposed to DBus, ready to receive function calls!');
}
